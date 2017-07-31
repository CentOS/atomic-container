#!/usr/bin/bash
# Original Source: https://github.com/docker-library/official-images/blob/master/test/tests/utc/run.sh
set -e

[ "$(docker run --rm --entrypoint date "$1" +%Z)" == "UTC" ]
