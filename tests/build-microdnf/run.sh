#!/bin/bash
# Original Source: https://github.com/docker-library/official-images/blob/master/test/tests/no-hard-coded-passwords/run.sh
set -e

EXIT_CODE=0
IMAGE=test/${RANDOM}

cat <<EOF |
FROM $1
RUN microdnf -y install epel-release
EOF
docker build -t ${IMAGE} - || EXIT_CODE=1
docker rmi -f ${IMAGE} || :

exit ${EXIT_CODE}
