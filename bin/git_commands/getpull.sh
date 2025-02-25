#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: git getpull <SHA>"
  exit 1
elif [ -z "$(git rev-parse --git-dir 2>/dev/null)" ]; then
  echo "Not in a git directory"
  exit 1
else
  repository_path=$(git config --get remote.origin.url 2>/dev/null | perl -lne 'print $1 if /(?:(?:https?:\/\/github.com\/)|:)(.*?).git/')
  pull_base_url=https://github.com/$repository_path/pull
  pull_id=$(git log $1^! --oneline 2>/dev/null | tail -n 3 | grep -oP '(?<=#)[0-9]*')
#  pull_id=$(git log $1..master --ancestry-path --merges --oneline 2>/dev/null | tail -n 1 | perl -nle 'print $1 if /#(\d+)/')

#  if [ -n "$pull_id" ]; then
    echo "$pull_base_url/$pull_id"
#  else
#    echo "Sorry, couldn't find that pull"
#    exit 1
#  fi
fi

