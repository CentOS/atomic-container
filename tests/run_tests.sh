#!/bin/bash

set -e

cat centos_atomic.tar | docker import - justbuilt/atomic

root_dir=`pwd`

for t in `find . -type d -maxdepth 0 `; do 
  cd ${t}
  if [ -e Dockerfile ]; then
    docker build -t justbuilt/${t} .
    if [ -e test.sh ]; then
      bash test.sh
    fi
  fi
  cd ${root_dir}
done
