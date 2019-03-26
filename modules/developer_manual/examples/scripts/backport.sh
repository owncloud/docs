#!/bin/bash

scriptDependencies=( curl git grep jq perl tail )

function checkDependencies() {
    for dependency in "${scriptDependencies[@]}"
    do
        if ! [ -x "$(command -v ${dependency})" ]; then
            echo "Error: ${dependency} is not installed." >&2
            echo "Please install package \"${dependency}\" before using this script"
            exit 1
        fi
    done
}

checkDependencies

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "  $0 <merge/commit-sha> <targetBranchName>"
    echo "  For example: $0 1234567 stable10"
    exit
fi

commit="$1"
targetBranch="$2"
baseBranch="$(git rev-parse --abbrev-ref HEAD)"

is_merged="$(git branch --contains $1 | grep -oP '(?<=\*).*')"
if [ -z "$is_merged" ]; then
    echo "${commit} has not been merged or branch ${baseBranch} is not pulled/rebased. Exiting"
    echo
    exit
fi

# Get the PR number from commit
pullId="$(git log $1^! --oneline 2>/dev/null | tail -n 3 | grep -oP '(?<=#)[0-9]*')"

# Get the repository from commit
repository="$(git config --get remote.origin.url 2>/dev/null | perl -lne 'print $1 if /(?:(?:https?:\/\/github.com\/)|:)(.*?).git/')"

# Get the list of commits in the PR without any merge commit.
# $1^ means the first parent of the merge commit (that is passed in as $1).
# Because $1 is a "magically-generated" merge commit, it happily "jumps back"
# to the point on the main branch just before where the PR was merged.
# And so the commits from that point are exactly the list of individual
# commits in the original PR.
# --no-merges leaves out the merge commit itself, and we get just what we want
commitList="$(git log --no-merges --reverse --format=format:%h $1^..$1)"

#. <( curl -i https://api.github.com/users/octocat 2>&1 | grep -P '^X-RateLimit-(Reset|Remaining)' | sed 's/X-RateLimit-/rateLimit/g; s/: /=/g;' )

# Get the request reset time window from github in epoch
rateLimitReset="$( echo $rateLimitInfo | grep -m1 'X-RateLimit-Reset:' | grep -o '[[:digit:]]*')"

# Get the remaining requests in window from GitHub
rateLimitRemaining="$( echo $rateLimitInfo | grep -m1 'X-RateLimit-Remaining:' | grep -o '[[:digit:]]*')"

# time remaining in epoch
now="$(date +%s)"
((remaining=rateLimitReset-now))

# Time remaining in HMS
remaining="$(date -u -d @${remaining} +%H:%M:%S)"

# Check if there are commits to cherry pick and list them in case
if [[ -z "$commitList" ]]; then
  echo "There are no commits to cherry pick. Exiting"
  exit
else
  lineCount="$(echo "$commitList" | grep '' | wc -l)"
  echo "${lineCount} commits being cherry picked:"
  echo
  echo "${commitList}"
fi

if (( "${rateLimitRemaining}" <= 0 )); then
  # Do not continue if there are no remaining github requests available
  echo "You do not have enough GitHub requests available to backport the PR."
  echo "The current rate limit window resets in ${remaining}."
  exit
else
  # Get the PR title, as this is the only automated valid way to get the title.
  pullTitle="$(curl https://api.github.com/repos/${repository}/pulls/${pullId} 2>/dev/null | jq '.title' | sed 's/^.//' | sed 's/.$//')"
fi

# Build names used
targetCommit="${targetBranch}-${commit}-${pullId}"
message="[${targetBranch}] [PR ${pullId}] ${pullTitle}"

echo
echo "Info:"
echo "You have ${rateLimitRemaining} backport requests remaining in the current GitHub rate limit window."
echo "The current rate limit window resets in ${remaining}."
echo
echo "Backporting commit ${commit} to ${targetBranch} with the following text:"
echo "${message}"
echo

set -e

git fetch -p --quiet
git checkout "${targetBranch}"
git pull --rebase --quiet
git checkout -b "${targetCommit}"

echo

# Cherry pick all commits from the commit list.
lC=1
echo "$commitList" | while IFS= read -r line; do
  echo "Cherry picking commit $lC: $line"
  # If you do not want to use a default conflict resolution to take theirs
  # (help fix missing cherry picked commits or file renames)
  #git cherry-pick $line > /dev/null
  git cherry-pick -Xtheirs $line > /dev/null
  lC=$(( $lC + 1 ))
done
echo

git commit --quiet --amend -m "${message}" -m "Backport of PR #${pullId}"

echo "Pushing: ${message}"
echo

git push --quiet -u origin "${targetCommit}"
git checkout --quiet "${baseBranch}"
