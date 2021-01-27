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
baseBranch=$(git rev-parse --abbrev-ref HEAD)

is_merged=$(git branch --contains $1 | grep -oP '(?<=\*).*')
if [ -z "$is_merged" ]; then
    echo "$commit has not been merged or branch $baseBranch is not pulled/rebased. Exiting"
    echo
    exit
fi

# get the PR number from commit
pullId=$(git log $1^! --oneline 2>/dev/null | tail -n 3 | grep -oP '(?<=#)[0-9]*')

# get the repository from commit
repository=$(git config --get remote.origin.url 2>/dev/null | perl -lne 'print $1 if /(?:(?:https?:\/\/github.com\/)|:)(.*?).git/')

# get the list of commits in PR without any merge commit
# $1^ means the first parent of the merge commit (that is passed in as $1).
# Because $1 is a "magically-generated" merge commit, it happily "jumps back"
# to the point on the main branch just before where the PR was merged.
# And so the commits from that point are exactly the list of individual
# commits in the original PR.
# --no-merges leaves out the merge commit itself, and we get just what we want
commitList=$(git log --no-merges --reverse --format=format:%h $1^..$1)

# get the request reset time window from github in epoch
rateLimitReset=$(curl -iks https://api.github.com/users/zen 2>&1 | grep -im1 'X-Ratelimit-Reset:' | grep -o '[[:digit:]]*')

# get the remaining requests in window from github
rateLimitRemaining=$(curl -iks https://api.github.com/users/zen 2>&1 | grep -im1 'X-Ratelimit-Remaining:' | grep -o '[[:digit:]]*')

# time remaining in epoch
now=$(date +%s)
((remaining=rateLimitReset-now))

# time remaining in HMS
remaining=$(date -u -d @$remaining +%H:%M:%S)

# check if there are commits to cherry pick and list them in case
if [[ -z "$commitList" ]]; then
  echo "There are no commits to cherry pick. Exiting"
  exit
else
  lineCount=$(echo "$commitList" | grep '' | wc -l)
  echo "$lineCount commits being cherry picked:"
  echo
  echo "$commitList"
fi

if [ $rateLimitRemaining -le 0 ]; then
  # do not continue if there are no remaining github requests available
  echo "You do not have enough github requests available to backport"
  echo "The current rate limit window resets in $remaining"
  exit 
else
  # get the PR title, this is the only automated valid way to get the title 
  pullTitle=$(curl https://api.github.com/repos/$repository/pulls/$pullId 2>/dev/null | jq '.title' | sed 's/^.//' | sed 's/.$//')
fi

# build names used
targetCommit="$targetBranch-$commit-$pullId"
message="[$targetBranch] [PR $pullId] $pullTitle"

echo
echo "Info:"
echo "You have $rateLimitRemaining backport requests remaining in the current github rate limit window"
echo "The current rate limit window resets in $remaining"
echo
echo "Backporting commit $commit to $targetBranch with the following text:"
echo "$message"
echo

set -e

git fetch -p --quiet
git checkout "$targetBranch"
git pull --rebase --quiet
git checkout -b "$targetCommit"

echo

# cherry pick all commits from commitList
lC=1
echo "$commitList" | while IFS= read -r line; do
  echo "Cherry picking commit $lC: $line"
  # if you do not want to use a default conflict resolution to take theirs
  # (help fix missing cherry picked commits or file renames)
  #git cherry-pick $line > /dev/null 
  git cherry-pick -Xtheirs $line > /dev/null 
  lC=$(( $lC + 1 ))
done
echo

git commit --quiet --amend -m "$message" -m "Backport of PR #$pullId"

echo "Pushing: $message"
echo

git push --quiet -u origin "$targetCommit"
git checkout --quiet "$baseBranch"

