#!/bin/bash
# Original Source: https://github.com/docker-library/official-images/blob/master/test/tests/cve-2014--shellshock/run.sh
set -e

DIR="$(readlink -f "$(dirname "$BASH_SOURCE")")"
docker run --rm -i --entrypoint bash \
	$1 <${DIR}/shellshock_test.sh
