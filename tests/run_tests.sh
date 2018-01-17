#!/bin/bash
set -e

TEST_DIR="$(readlink -f "$(dirname "${BASH_SOURCE}")")"
IMAGE_TAR_NAME="${IMAGE_TAR_NAME:-centos_atomic.tar.gz}"
IMAGE_TAR="${1:-$(readlink -f "$(dirname ${TEST_DIR})")/${IMAGE_TAR_NAME}}"
IMAGE_NAME=build/centos-atomic:${RANDOM}

function log() {
  echo "[$(date)][${2:-INFO }] $1"
}

function error() {
  echo 2>&1 "[ERROR] $1"
  exit 1
}

[[ -f "${IMAGE_TAR}" ]] || error "Image layer tarball not found at ${IMAGE_TAR}"

log "Importing ${IMAGE_TAR} as ${IMAGE_NAME}"
{ cat "${IMAGE_TAR}" | docker import - ${IMAGE_NAME}; } \
  || error "Failed to import image"

EXIT_CODE=0

for t in `find ${TEST_DIR} -mindepth 1 -maxdepth 1 -type d`;
do
  test_name=$(basename ${t})
  log "[${test_name}] Executing test"
  run_script="${t}/run.sh"
  [[ -f "${run_script}" ]] || {
    log "[${test_name}] ${run_script} not found" "SKIP ";
    continue;
  }
  { bash ${run_script} ${IMAGE_NAME} && result="PASS "; } \
    || { EXIT_CODE=1; result="FAIL "; }
  log "[${test_name}] Completed test" "${result}"
done

# clean up after tests
log "Deleting ${IMAGE_NAME}"
docker rmi -f ${IMAGE_NAME} || :

exit ${EXIT_CODE}
