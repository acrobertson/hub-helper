#!/bin/bash

usage() {
    echo "Usage: hub-pr [-t TITLE] [-m MSG]. With no arguments, run hub pull-request --no-edit" 1>&2
}

# Default behavior is create the PR using --no-edit
if [ $# -eq 0 ]; then
    hub pull-request --no-edit
    exit 0
fi

# Otherwise, check for title and message args
while getopts ":t:m:" opt; do
    case ${opt} in
        t) TITLE=${OPTARG};;
        m) MSG=${OPTARG};;
        \? ) usage; exit 1
    esac
done

if [ -z "$TITLE" ]; then
    usage
    exit 1
fi

if [ -z "$MSG" ]; then
    usage
    exit 1
fi

hub pull-request -m "$TITLE" -m "$MSG"
exit 0
