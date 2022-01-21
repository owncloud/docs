#!/bin/bash
# version 2022.01.21

if ! [ -x "$(command -v jq)" ]; then
  echo
  echo 'Error: jq is not installed.' >&2
  echo 'Please install package "jq" before using this script'
  echo
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo
  echo 'Error: curl is not installed.' >&2
  echo 'Please install package "curl" before using this script'
  echo
  exit 1
fi

if [ "$#" -lt 2 ]; then
  echo
  echo "Illegal number of parameters"
  echo "  $0 <merge/commit-sha> <targetBranchName>"
  echo "  For example: $0 1234567 10.8"
  echo
  exit 1
fi

commit=$1
targetBranch=$2
sourceBranch=$(git rev-parse --abbrev-ref HEAD)

# check if the target branch exists on remote to avoid backporting to a non existing remote branch
exists_in_remote=$(git ls-remote --heads origin ${targetBranch})
if [ -z "${exists_in_remote}" ]; then
    echo
    echo "Branch ${targetBranch} does not exist on remote. Create it first. Exiting"
    echo
    exit 1
fi

# check if the target branch already exists locally
exists_in_local=$(git branch --list ${targetBranch})
if [ -z "${exists_in_local}" ]; then
    echo
    echo "Branch ${targetBranch} does not exist locally. Make it available first. Exiting"
    echo
    exit 1
fi

# check if the given merge commit exists in the actual checked out branch
is_merged=$(git branch --contains $1 2>/dev/null | grep -oP '(?<=\*).*')
if [ -z "${is_merged}" ]; then
    echo
    echo "${commit} does not exist because:"
    echo "- the PR has not been merged yet or"
    echo "- your actual backporting base branch ${sourceBranch} is not pulled/rebased."
    echo "Exiting"
    echo
    exit 1
fi

# get the PR number from the merge commit
# there can be a PR reference text in the commit like "fixes #1234".
# we only need to take the last line which is then the real PR # the commit belongs to
pullId=$(git log $1^! --oneline 2>/dev/null | tail -n 3 | grep -oP '(?<=#)[0-9]*' | tail -n 1)

# get the repository from the given commit
# remove prefix and suffix from the full url returned
repository=$(git config --get remote.origin.url 2>/dev/null)
repository=${repository#"https://github.com/"}
repository=${repository%".git"}

# get the list of commits in PR without any merge commit
# $1^ means the first parent of the merge commit (that is passed in as $1).
# because $1 is a "magically-generated" merge commit, it happily "jumps back"
# to the point on the main branch just before where the PR was merged.
# the commits from that point are exactly the list of individual
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
remaining=$(date -u -d @${remaining} +%H:%M:%S)

# echo one time for a good rendering
echo

# check if there are commits to cherry pick and list them if present
if [[ -z "${commitList}" ]]; then
  echo "There are no commit(s) to cherry pick. Exiting"
  echo
  exit 1
else
  lineCount=$(echo "${commitList}" | grep '' | wc -l)
  echo "${lineCount} commit(s) to be cherry picked:"
  echo
  echo "${commitList}"
  echo
fi

if [ ${rateLimitRemaining} -le 0 ]; then
  # do not continue if there are no remaining github requests available
  echo
  echo "You do not have enough github requests available to backport"
  echo "The current rate limit window resets in ${remaining}"
  echo
  exit 1 
else
  # get the PR title, this is the only automated valid way to get the title 
  pullTitle=$(curl https://api.github.com/repos/"${repository}"/pulls/"${pullId}" 2>/dev/null | jq '.title' | sed 's/^.//' | sed 's/.$//')
  # remove possible line breaks on any location in the string
  pullTitle=${pullTitle//$'\n'/}
fi

# build variables for later use
newBranch="${targetBranch}-${commit}-${pullId}"
message="[${targetBranch}] [PR ${pullId}] ${pullTitle}"

# first check, if the source branch is clean and has no uncommitted changes
# in case this is true, checkout does not succeed and nothing needs to be done/switched
# xargs removes any possible leading and trailing whitespaces
is_source_branch_clean=$(git status --porcelain=v1 2>/dev/null | xargs)
if [[ ! -z "${is_source_branch_clean}" ]]; then
  echo "Source branch ${sourceBranch} has probably uncommitted changes. Aborting."
  echo
  exit 1
fi

# exit the script if any statement returns a non-true return value
# means that all commands from now on must run successfully
set -e

# fetch branches and/or tags from one or more other repositories, along with the
# objects necessary to complete their histories
git fetch -p --quiet

# checkout and rebase the target branch
git checkout "${targetBranch}" --quiet

# if everything is ok, then rebase the target branch
git pull --rebase --quiet

# create a new branch based on the target branch
# the new branch name equals the new commit name
git checkout -b "${newBranch}" "${targetBranch}" 

echo

# cherry pick all commits from commitList
lC=1
echo "${commitList}" | while IFS= read -r line; do
  # start cherry-picking
  echo "Cherry picking commit ${lC}: ${line}"

  # check if the commit to be cherry picked is already in the branch
  # this only works if the commit was cherry picked before!
  # else it will just try and continue.
  is_cherry_picked=$(git log --grep "${line}" 2>/dev/null)
  if [[ ! -z "${is_cherry_picked}" ]]; then
    echo
    echo "Commit ${line} has aready been cherry picked, abort backporting."
    # go back to the base branch and delete the new branch with all its contents.
    git checkout --quiet "${sourceBranch}"
    git branch -D --quiet "${newBranch}"
    echo
    exit 1
  fi

  # pull this commit into the new branch
  # if you do not want to use a default conflict resolution to take theirs
  # (help fix missing cherry picked commits or file renames)
  #git cherry-pick ${line} > /dev/null 
  git cherry-pick -Xtheirs "${line}" > /dev/null 
  lC=$(( ${lC} + 1 ))
done

echo
echo "Committing changes"
echo

## rewrite the most recent commit message
## the first -m creates the PR headline text
## the second -m creates the PR message text
git commit --quiet --amend -m "${message}" -m "Backport of PR #${pullId}"

echo "Pushing: ${message}"
echo

git push --quiet -u origin "${newBranch}"
git checkout --quiet "${sourceBranch}"
