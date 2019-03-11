#!/bin/bash

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  echo 'Please install package "jq" before using this script'
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  echo 'Please install package "curl" before using this script'
  exit 1
fi

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "  $0 <merge/commit-sha> <targetBranchName>"
    echo "  For example: $0 1234567 stable10"
    exit
fi

commit=$1
targetBranch=$2

is_merged=$(git branch --contains $1 | grep -oP '(?<=\*).*')

if [ -z "$is_merged" ]; then
    echo "$commit has not been merged or branch is not pulled/rebased. Exiting"
    echo
    exit
fi

# get the PR number from commit
pullId=$(git log $1^! --oneline 2>/dev/null | tail -n 3 | grep -oP '(?<=#)[0-9]*')

# get the repository from commit
repository=$(git config --get remote.origin.url 2>/dev/null | perl -lne 'print $1 if /(?:(?:https?:\/\/github.com\/)|:)(.*?).git/')

# get the request reset time window from github in epoch
rateLimitReset=$(curl -i https://api.github.com/users/octocat 2>&1 | grep -m1 'X-RateLimit-Reset:' | grep -o '[[:digit:]]*')

# get the remaining requests in window from github
rateLimitRemaining=$(curl -i https://api.github.com/users/octocat 2>&1 | grep -m1 'X-RateLimit-Remaining:' | grep -o '[[:digit:]]*')

# time remaining in epoch
now=$(date +%s)
((remaining=rateLimitReset-now))

# time remaining in HMS
remaining=$(date -u -d @$remaining +%H:%M:%S)

if [ $rateLimitRemaining -le 0 ]; then
  # do not continue if there are no remaining github requests available
  echo "You do not have enough github requests available to backport"
  echo "The current rate limit window resets in $remaining"
  exit 
else
  # get the PR title, this is the only automated valid way to get the title 
  pullTitle=$(curl https://api.github.com/repos/$repository/pulls/$pullId 2>/dev/null | jq '.title' | sed 's/^.//' | sed 's/.$//')
fi

echo
echo "Info:"
echo "You have $rateLimitRemaining backport requests remaining in the current github rate limit window"
echo "The current rate limit window resets in $remaining"
echo
echo "Backporting commit $commit to $targetBranch"
echo

# build names used
targetCommit=$targetBranch-$commit-$pullId
message="[$targetBranch] [PR $pullId] $pullTitle"

set -e

git fetch -p
git checkout $targetBranch
git pull --rebase
git checkout -b $targetCommit

echo

git cherry-pick $commit || git cherry-pick -m 1 $commit

echo

git commit --amend -m "$message"

echo
echo "Pushing: $message"
echo

git push origin $targetCommit
