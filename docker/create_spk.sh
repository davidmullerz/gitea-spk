#!/bin/sh

set -e

# Determines the binary for which the package should be build.
select_binary()
{
    local args=$1
    local binary=""

    if [ "${args##http}" != "$args" ]; then
        cd /tmp
        binary=$(curl -w '%{filename_effective}' -OskL $args)
        if [ ! $? -eq 0 ]; then
            echo >&2 "Error: cannot download $1"
            exit 1
        fi
        case $binary in
            *.gz) gunzip $binary; binary=$(basename $binary .gz) ;;
            *.bz2) bunzip2 $binary; binary=$(basename $binary .bz2) ;;
            *.xz) xz -d $binary; binary=$(basename $binary .xz) ;;
        esac
    elif [ -d "$args" ]; then
        cd "$args"
        # pick the latest binary
        binary=$(ls -1 -t gitea-*-linux-*[!.spk] 2>/dev/null | head -1)
        if [ ! $? -eq 0 ]; then
            echo >&2 "No gitea binary found. Please download a binary from https://github.com/go-gitea/gitea/releases"
            exit 1
        fi
    elif [ ! -f "$args" ]; then
        echo >&2 "Error: $args not found"
        exit 1
    fi

    binary=$(readlink -f $binary)
    echo "$binary"
}


# Determines the version number of the given Gitea binary.
get_version()
{
    local binary="$1"

    basename ${binary} | sed 's/[^0-9.]*\([0-9.]*\).*/\1/'
}


# Determines the platform identifier of the given Gitea binary.
get_platform()
{
    local binary="$1"

    basename ${binary} | sed 's/.*linux-\(.*\)/\1/'
}


# Determines the Synology arch values for the given Gitea binary.
get_arch()
{
    local binary="$1"
    local platform=`get_platform ${binary}`

    # lookup the arch values for the given platform in the mappings file
    grep "^$platform " "arch.desc" | awk '{for (i=2; i<=NF; i++) printf "%s ", $i}' | xargs
}


# Updates the package metadata to reflect the given Gitea binary.
update_metadata()
{
    local version="$1"
    local arch="$2"

    if [ "$arch" = "" ]; then
        echo "${binary} is not a supported platform"
        exit 1
    fi

    cp 2_create_project/INFO.in 2_create_project/INFO

    sed -i -e "s/[0-9]\+\.[0-9]\+\.[0-9]\+/$version/" 2_create_project/INFO
    sed -i -e "s#arch=\".*\"#arch=\"$arch\"#" 2_create_project/INFO
}


# Builds the package for the given Gitea binary.
build()
{
    local current=$PWD
    local binary=$1
    local spk=$2

    cd $(dirname $0)

    version=`get_version $binary`
    arch=`get_arch $binary`

    echo "binary: $binary"
    echo "version: $version"
    echo "arch: $arch"

    update_metadata "$version" "$arch"

    chmod +x $binary
    mkdir -p 1_create_package/gitea
    ln -sf $binary 1_create_package/gitea/gitea

    cd 1_create_package
    tar cfhz ../2_create_project/package.tgz *

    cd ../2_create_project/
    tar cfz ${spk} --exclude=INFO.in *

    rm -f package.tgz
    cd $current
}


binary=$(select_binary $1)
spk=/spk/$(basename ${binary}).spk

build ${binary} ${spk}

chown ${UID:-0} ${spk}
ls -l ${spk}
