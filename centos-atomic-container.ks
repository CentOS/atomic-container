# This is a minimal CentOS install designed to serve as a Docker base image.
#
# To keep this image minimal it only installs English language. You need to change
# dnf configuration in order to enable other languages.
#
###  Hacking on this image ###
# We assume this runs on a CentOS Linux 7/x86_64 machine, with virt ( or nested virt ) 
# enabled, use the build.sh script to build your own for testing

#version=CentOS7
# Keyboard layouts
keyboard 'us'
# Reboot after installation
reboot
# Root password
rootpw --iscrypted --lock locked
# System language
lang en_US
user --name=none
# Firewall configuration
firewall --disabled
repo --name="microdnf" --baseurl="http://mirror.centos.org/centos/7/atomic/x86_64" --cost=100
repo --name="updates" --baseurl="http://mirror.centos.org/centos/7/updates/x86_64"

# System timezone
timezone UTC --isUtc --nontp
# System bootloader configuration
bootloader --disabled
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all
# Disk partitioning information
part / --fstype="ext4" --grow

%post --logfile /var/log/anaconda/anaconda-post.log

# remove the user anaconda forces us to make
userdel -r none

# Set the language rpm nodocs transaction flag persistently in the
# image yum.conf and rpm macros

LANG="en_US"
echo "%_install_lang $LANG" > /etc/rpm/macros.image-language-conf

awk '(NF==0&&!done){print "override_install_langs='$LANG'\ntsflags=nodocs";done=1}{print}' \
    < /etc/yum.conf > /etc/yum.conf.new
mv /etc/yum.conf.new /etc/yum.conf

#systemd wrongly expects "unpopulated /etc" when /etc/machine-id does not exist
#let's leave machine-id empty
cat /dev/null > /etc/machine-id

#https://bugzilla.redhat.com/show_bug.cgi?id=1235969
#rm -f /etc/fstab
#this is not possible, guestmount needs fstab => brew build crashes without it
#fstab is removed in TDL when tar-ing files

rm -f /usr/lib/locale/locale-archive
#setup at least some locale, https://bugzilla.redhat.com/show_bug.cgi?id=1129697
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8

#https://bugzilla.redhat.com/show_bug.cgi?id=1201663
rm -f /etc/systemd/system/multi-user.target.wants/rhsmcertd.service

#content of /run can not be prepared if /run is tmpfs (disappears on reboot)
umount /run
systemd-tmpfiles --create --boot

rpm -e acl audit-libs binutils cpio cracklib cracklib-dicts cryptsetup-libs dbus dbus-libs device-mapper device-mapper-libs diffutils dracut elfutils-libs gzip hardlink kmod kmod-libs kpartx libcap-ng libpwquality libsemanage libuser libutempter pam procps-ng qrencode-libs shadow-utils systemd systemd-libs tar ustr util-linux xz qemu-guest-agent

#create /etc/yum.repos.d, microdnf needs it but does not provide it
mkdir -p /etc/yum.repos.d/

rm /usr/share/gnupg/help*.txt -f
KEEPLANG=en_US
for dir in locale i18n; do
    find /usr/share/${dir} -mindepth  1 -maxdepth 1 -type d -not \( -name "${KEEPLANG}" -o -name POSIX \) -exec rm -rf {} +
done
rm /usr/lib/rpm/rpm.daily
rm /usr/lib64/nss/unsupported-tools/ -rf
rm /usr/share/gcc*/python -rf
rm /usr/sbin/{glibc_post_upgrade.x86_64,sln}
#let us not lie that blatantly
#ln /usr/bin/ln /usr/sbin/sln
rm -rf /var/lib/yum
rm -rf /var/cache/* /var/log/* /tmp/*
rm -rf /usr/lib/udev /etc/yum /etc/dbus-1 /usr/share/dbus-1
rm -rf /usr/share/icons/*

#some random not-that-useful binaries
rm -f /usr/bin/oldfind
rm -f /usr/bin/pinky
rm -f /usr/bin/script


#we lose presets by removing /usr/lib/systemd but we do not care
rm -rf /usr/lib/systemd
#https://bugzilla.redhat.com/show_bug.cgi?id=1476674 should not be affected

#if you want to change the timezone, bind-mount it from the host or reinstall tzdata
rm -f /etc/localtime
mv /usr/share/zoneinfo/UTC /etc/localtime
rm -rf  /usr/share/zoneinfo

#udev hardware database not needed in a container
rm -f /etc/udev/hwdb.bin
rm -rf /usr/lib/udev/hwdb.d/*


rm -rf /var/cache/yum/*
rm -f /tmp/ks-script*

%end

%packages --excludedocs --nobase --nocore --instLangs=en
bash
centos-release
microdnf
systemd
-e2fsprogs
-firewalld
-kernel
-kexec-tools
-xfsprogs

%end
