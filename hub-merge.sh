#!/bin/bash

usage() {
    echo "Usage: hub-merge [-f]. Run with -f to push the merge commit and close the PR" 1>&2
}

NUM_PRS=`hub pr list | wc -l`
if [ $NUM_PRS -gt 1 ]; then
    echo "Error: There are multiple open pull requests" 1>&2
    exit 1
fi

while getopts ":f" opt; do
    case ${opt} in
        f) FORCE=1;;
        \? ) usage; exit 1
    esac
done

PR_URL=`hub pr list -f "%U"`
PR_NUM=`hub pr list -f "%I"`
PR_MSG="Merge pull request #${PR_NUM} from `hub pr list -f "%au/%B"`"

if [ -z "$PR_URL" ]; then
    echo "Error: Couldn't find pull request url" 1>&2
    exit 1
fi

if [ -z "$PR_NUM" ]; then
    echo "Error: Couldn't find pull request number" 1>&2
    exit 1
fi

git remote -v | grep upstream > /dev/null 2>&1
if [ $? -eq 0 ]; then
    REMOTE="upstream"
else
    git remote -v | grep origin > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        REMOTE="origin"
    else
        echo "Error: Could find a valid git remote (origin or upstream)" 1>&2
        exit 1
    fi
fi

hub merge $PR_URL
git fetch $REMOTE refs/pull/${PR_NUM}/head
git merge FETCH_HEAD --no-ff -m "$PR_MSG"

if [ $FORCE -eq 1 ]; then
    git push $REMOTE
else
    echo "Merge complete: Push this branch to the remote repository to close the pull request" 1>&2
fi
