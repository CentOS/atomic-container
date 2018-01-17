#!/bin/bash

set -eux;

DOCKERFILE="Dockerfile";
export IMAGE_TAR_NAME="centos_atomic.tar.gz";

bash build.sh
cat >${DOCKERFILE} <<EOF
FROM scratch
ADD ${IMAGE_TAR_NAME} /
ENTRYPOINT ["/bin/bash"]
EOF
