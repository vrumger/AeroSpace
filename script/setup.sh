#!/usr/bin/env bash
set -e # Exit if one of commands exit with non-zero exit code
set -u # Treat unset variables and parameters other than the special parameters ‘@’ or ‘*’ as an error
set -o pipefail # Any command failed in the pipe fails the whole pipe
# set -x # Print shell commands as they are executed (or you can try -v which is less verbose)

cmd-exist() {
    command -v "$1" &> /dev/null
}

setup() {
    mkdir -p .deps/bin

    cmd-exist git            && ln -fs "$(which git)" .deps/bin/git
    cmd-exist cargo          && ln -fs "$(which cargo)" .deps/bin/cargo
    cmd-exist rustc          && ln -fs "$(which rustc)" .deps/bin/rustc
    cmd-exist xcbeautify     && ln -fs "$(which xcbeautify)" .deps/bin/xcbeautify
    cmd-exist fish           && ln -fs "$(which fish)" .deps/bin/fish
    cmd-exist bash           && ln -fs "$(which bash)" .deps/bin/bash
    cmd-exist bundle         && ln -fs "$(which bundle)" .deps/bin/bundle # Ruby, asciidoc
    cmd-exist bundler        && ln -fs "$(which bundler)" .deps/bin/bundler # Ruby, asciidoc
    cmd-exist brew           && ln -fs "$(which brew)" .deps/bin/brew # install-release.sh

    tmp=(
        "${PWD}/.deps/bin"
        /bin # cat
        /usr/bin # xcodebuild, zip, arch
    )

    IFS=':'
    export PATH=${tmp[*]}
    unset IFS
}

if [ -z "${SETUP_SH:-}" ]; then
    export SETUP_SH=true
    setup
fi

xcodebuild() {
    # Mute stderr
    # 2024-02-12 23:48:11.713 xcodebuild[60777:7403664] [MT] DVTAssertions: Warning in /System/Volumes/Data/SWE/Apps/DT/BuildRoots/BuildRoot11/ActiveBuildRoot/Library/Caches/com.apple.xbs/Sources/IDEFrameworks/IDEFrameworks-22269/IDEFoundation/Provisioning/Capabilities Infrastructure/IDECapabilityQuerySelection.swift:103
    # Details:  createItemModels creation requirements should not create capability item model for a capability item model that already exists.
    # Function: createItemModels(for:itemModelSource:)
    # Thread:   <_NSMainThread: 0x6000037202c0>{number = 1, name = main}
    # Please file a bug at https://feedbackassistant.apple.com with this warning message and any useful information you can provide.
    if cmd-exist xcbeautify; then
        /usr/bin/xcodebuild "$@" 2>&1 | xcbeautify --quiet # Only print tasks that have warnings or errors
    else
        /usr/bin/xcodebuild "$@" 2>&1
    fi
}
