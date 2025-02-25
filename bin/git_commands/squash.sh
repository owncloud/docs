#!/bin/bash
# squash the number of commits to one with a defined commit message

#get number of commits to squash
squashCount=$1

#get the commit message
shift
commitMsg=$@

#regular expression to verify that squash number is an integer
regex='^[0-9]+$'

echo "---------------------------------"
echo "Will squash $squashCount commits"
echo "Commit message will be '$commitMsg'"

echo "...validating input"

if ! [[ $squashCount =~ $regex ]]
then
    echo "Squash count must be an integer."
elif [ -z "$commitMsg" ]
then
    echo "Invalid commit message.  Make sure string is not empty"
else
    echo "...input looks good"
    echo "...proceeding to squash"
    git reset --soft HEAD~$squashCount
    git commit -m "$commitMsg"
    echo "...done"
fi



echo

exit 0

