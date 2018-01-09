MAKEFILE_PATH     := $(abspath $(lastword $(MAKEFILE_LIST)))
ROOT_DIR          := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))

DOCKER_REPO       ?= docker.io
DOCKER_IMAGE_NAME ?= centos-atomic
DOCKER_IMAGE_TAG  ?= latest
DOCKER_IMAGE      ?= $(DOCKER_REPO)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
TAR               ?= centos_atomic.tar.gz

_VM_DOMAIN        := centos_atomic_image
_VM_POOL          := default

.PHONY: all clean clean/image clean/libvirt clean/rootfs rootfs image tests push

all: | rootfs test image

define delete_libvirt_image
	sudo virsh undefine $(_VM_DOMAIN)
	sudo virsh vol-delete $(_VM_DOMAIN).img --pool $(_VM_POOL)
endef

clean/libvirt:
	$(call delete_libvirt_image)

$(TAR):
	@sudo VM_DOMAIN=$(_VM_DOMAIN) bash $(ROOT_DIR)/build.sh
	$(call delete_libvirt_image)

clean/rootfs:
	@rm -rf $(TAR)

rootfs: $(TAR)

clean/image:
	docker rmi -f $(DOCKER_IMAGE) || :

image: rootfs
	docker import $(TAR) $(DOCKER_IMAGE)

test: rootfs
	@bash ./tests/run_tests.sh ${TAR}

push:
	@docker push $(DOCKER_IMAGE)

clean: clean/rootfs clean/image
