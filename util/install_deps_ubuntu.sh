#!/usr/bin/env bash
# Use: install_deps_ubuntu.sh [ assume-yes ]

set -ev

SUDO=${SUDO:=sudo} # SUDO=command in docker (running as root, sudo not available)
if [ "$1" == "assume-yes" ]; then
    APT_CONFIRM="--assume-yes"
else
    APT_CONFIRM=""
fi

deps=(
    git
    # Open3D
    xorg-dev
    libxcb-shm0
    libglu1-mesa-dev
    python3-dev
    # Filament build-from-source
    clang
    libc++-dev
    libc++abi-dev
    libsdl2-dev
    ninja-build
    libxi-dev
    # ML
    libtbb-dev
    # Headless rendering
    libosmesa6-dev
    # RealSense
    libudev-dev
    autoconf
    libtool
)

eval $(
    source /etc/lsb-release;
    echo DISTRIB_ID="$DISTRIB_ID";
    echo DISTRIB_RELEASE="$DISTRIB_RELEASE"
)
if [ "$DISTRIB_ID" == "Ubuntu" -a "$DISTRIB_RELEASE" == "20.04" ]; then
    # Ubuntu 20.04's clang/libc++-dev/libc++abi-dev are version 8, 10 or 12.
    # To avoid dependence on libunwind, we don't want to use versions later than 10.
    deps=("${deps[@]/clang/clang-10}")
    deps=("${deps[@]/libc++-dev/libc++-10-dev}")
    deps=("${deps[@]/libc++abi-dev/libc++abi-10-dev}")
fi

# Special case for ARM64
if [ "$(uname -m)" == "aarch64" ]; then
    # For compling LAPACK in OpenBLAS
    deps+=("gfortran")
fi

echo "apt-get install ${deps[*]}"
$SUDO apt-get update
$SUDO apt-get install ${APT_CONFIRM} ${deps[*]}
