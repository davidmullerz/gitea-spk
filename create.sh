#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 <url>"
    echo "Please get an <url> from https://github.com/go-gitea/gitea/releases"
    exit 2
fi

docker build --tag create-spk docker/

docker run --rm -ti -v $PWD:/spk -e UID=$UID create-spk $1
