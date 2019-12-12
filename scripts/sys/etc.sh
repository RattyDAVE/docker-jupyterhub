#!/usr/bin/env bash

function run_scripts_etc.usage() {
    cat << EOF
Run scripts in /scripts/etc_pre or /scripts/etc_post which are for automatic configurations in Docker container.
Syntax: run_scripts_etc [upper_index]
Argument:
    upper_index: The maximum index of scripts to run.
EOF
}

function run_scripts_etc() {
    if [ "$1" == "-h" ]; then
        run_scripts_etc.usage
        return 0
    fi
    local upper_index=9${2:-999}
    local script
    for script in $(ls /scripts/etc_$1/[0-9][0-9][0-9]-*.sh); do
        local index=$(basename $script)
        index=9${index:0:3}
        if [[ $index -le $upper_index ]]; then
            source $script
        fi
    done
}

if [ "$0" == ${BASH_SOURCE[0]} ]; then
    run_scripts_etc $@
fi
