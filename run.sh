#!/usr/bin/env bash

if [ ! -f "$1" ]; then
    echo "Usage: $0 binary"
    echo "Please download a binary from https://github.com/go-gitea/gitea/releases"
    exit 2
fi

binary=$(basename $1)
bin_dir=$(cd $(dirname $1); pwd)

docker build --quiet --tag create-spk:latest .

docker run --rm -ti -v ${bin_dir}:/data create-spk ${binary}
