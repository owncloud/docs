#!/bin/bash

# This script prepares the parameters for owncloud_prep.sh
# Handy if you have more instances to maintain where the process stays the same with different parameters
# The processing script is expected in the same directory of this script.

# To setup this script for your environment, adopt the following variables to your needs:
#
# ocname        the name of your directory containing the owncloud files
# ocroot        the path to ocname, usually /var/www (no trailing slash)
# linkroot      the path to your source directory for linking data and apps-external (no trailing slash)
# htuser        the webserver user
# htgroup       the webserver group
# rootuser      the root user

ocname='owncloud'
ocroot='/var/www'

linkroot='/mnt/owncloud_data'

htuser='www-data'
htgroup='www-data'
rootuser='root'

if [ "$(id -u)" != 0 ]; then
  printf "\nThis script should be run as root user to allow filesystem modifications\nExiting\n\n"
fi

# Resolve the absolute path this script is located and expects the called script to be there too
# https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

$DIR/owncloud_prep.sh "$ocname" "$ocroot" "$linkroot" "$htuser" "$htgroup" "$rootuser"

