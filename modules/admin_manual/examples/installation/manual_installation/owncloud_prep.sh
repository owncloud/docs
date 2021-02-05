#!/bin/bash

# To setup this script for your environment, hand over the following variables according your needs:
#
# ocname        the name of your directory containing the owncloud files
# ocroot        the path to ocname, usually /var/www (no trailing slash)
# linkroot      the path to your source directory for linking data and apps-external (no trailing slash)
# htuser        the webserver user
# htgroup       the webserver group
# rootuser      the root user

# Short description for paramters used in find
#
# -L       ... Follow symbolic links. Needed in case if links are used or present
# -path    ... The path to process
# -prune   ... If the file is a directory, do not descend into it (used to exclude directories)
# -o       ... OR (to add more parameters)
# -type    ... File is of type [d ... directory, f ... file]
# -print0  ... Print the full file name on the standard output, followed by a null character
# xargs -0 ... Reads items from the standard input, input items are terminated by a null character


ocname=$1
ocroot=$2
ocpath=$ocroot/$ocname
ocdata=$ocroot/$ocname/'data'
ocapps_external=$ocpath/'apps-external'
oldocpath=$ocroot/$ocname'_'$(date +%F-%H.%M.%S)

linkroot=$3
linkdata=$linkroot/'data'
linkapps_external=$linkroot/'apps-external'

htuser=$4
htgroup=$5
rootuser=$6

arguments=6

filmod="0640"
dirmod="0750"
htamod="0644"

# Because the data directory can be huge or on external storage, an automatic chmod/chown can take a while.
# Therefore this directory can be treated differently.
# If you have already created an external "data" and "apps-external" directory which you want to link,
# set the paths above accordingly. This script can link and set the proper rights and permissions
# depending what you enter when running the script.

# When the instance is setup either post a fresh install or after an upgrade, run this script again but
# only for securing ".htaccess files". This sets the appropriate ownership and permission for them.

# In case you upgrade an existing installation, your original directory will be renamed including a timestamp


if [ "$#" -ne "$arguments" ]; then
  printf "\nThis script needs $arguments arguments, $# given.\n\n"
fi

printf "\nFollowing parameters used\n\n"
printf "ocname: $ocname\nocroot: $ocroot\nlinkroot: $linkroot\nhtuser: $htuser\nhtgroup:  $htgroup\nrootuser:  $rootuser\n"

function get_tar {
  read -p "Please specify the tar file to extract with full path: " -r -e tarFile
  if [ ! -f "$tarFile" ]; then
    echo "tar file to extract not found. Exiting."
    echo
    exit
  fi
}

echo

read -p "Do you want to secure your .htaccess files post installing/upgrade (y/N)? " -r -e answer
(echo "$answer" | grep -iq "^y") && do_secure="y" || do_secure="n"

if [ "$do_secure" = "y" ]; then
  printf "\nSecuring .htaccess files with chmod/chown\n"
  if [ -f ${ocpath}/.htaccess ]; then
    chmod $htamod ${ocpath}/.htaccess
    chown ${rootuser}:${htgroup} ${ocpath}/.htaccess
  fi
  if [ -f ${ocdata}/.htaccess ];then
    chmod $htamod ${ocdata}/.htaccess
    chown ${rootuser}:${htgroup} ${ocdata}/.htaccess
  fi
  printf "\nDone\n\n"
  exit
fi


read -p "Do you want to install a new instance (y/N)? " -r -e answer
(echo "$answer" | grep -iq "^y") && do_new="y" || do_new="n"


if [ "$do_new" = "n" ]; then
    read -p "Do you want to upgrade an existing installation (y/N)? " -r -e answer
    (echo "$answer" | grep -iq "^y") && do_upgrade="y" || do_upgrade="n"
fi

read -p "Use links for data and apps-external directories (Y/n)? " -r -e answer
(echo "$answer" | grep -iq "^n") && uselinks="n" || uselinks="y"

if [ "$uselinks" = "y" ]; then
  read -p "Do you want to chmod/chown these links (y/N)? " -r -e answer
  (echo "$answer" | grep -iq "^y") && chmdir="y" || chmdir="n"
fi

# check if upgrading an existing installation
if [ "$do_upgrade" = "y" ]; then
  read -p "Is the instance in maintenance mode? (y/N)? " -r -e answer
  (echo "$answer" | grep -iq "^y") && mmode="y" || mmode="n"
  if [ "$mmode" = "n" ]; then
    echo "Please enable maintenance mode first: sudo -u$htuser ./occ maintenance:mode --on"
    echo
    exit
  fi
  get_tar
  # rename the source for backup reasons
  if [ -d ${ocpath} ]; then
    mv $ocpath $oldocpath
  fi
fi

# get the tar file for new installs
if [ "$do_new" = "y" ]; then
  get_tar
fi

# in case of upgrade or new, extrect the source
if [ "$do_upgrade" = "y" ] || [ "$do_new" = "y" ]; then
  mkdir -p $ocpath
  tar xvf "$tarFile" -C $ocpath --strip-components=1

  if [ $? != 0 ]; then
    echo
    echo "tar extract failed, please check !"
    echo
    # rename back in case of tar errors
    if [ "$do_upgrade" = "y" ] && [ -d ${oldocpath} ]; then
      rm -r $ocpath
      mv $oldocpath $ocpath
    fi
    exit
  fi
fi

# create / link missing directories
printf "\nCreating or linking possible missing directories \n"
mkdir -p $ocpath/updater
# check if directory creation is possible and create if ok
if [ "$uselinks" = "n" ]; then
  if [ -L ${ocdata} ]; then
    echo "Symlink for $ocdata found but mkdir requested. Exiting."
    echo
    exit
  else
    echo "mkdir $ocdata"
    echo
    mkdir -p $ocdata
  fi
  if [ -L ${ocapps_external} ]; then
    echo "Symlink for $ocapps_external found but mkdir requested. Exiting."
    echo
    exit
  else
    printf "mkdir $ocapps_external \n"
    mkdir -p $ocapps_external
  fi
else
  if [ -d ${ocdata} ] && [ ! -L $ocdata ]; then
    echo "Directory for $ocdata found but link requested. Exiting."
    echo
    exit
  else
    printf "ln $ocdata --> $linkdata\n"
    mkdir -p $linkdata
    ln -sfn $linkdata $ocdata
  fi
  if [ -d ${ocapps_external} ] && [ ! -L $ocapps_external ]; then
    echo "Directory for $ocapps_external found but link requested. Exiting."
    echo
    exit
  else
    printf "ln $ocapps_external --> $linkapps_external\n"
    mkdir -p $linkapps_external
    ln -sfn $linkapps_external $ocapps_external
  fi
fi

# copy an existing config.php
if [ "$do_upgrade" = "y" ]; then
  if [ -f ${oldocpath}/config/config.php ]; then
    printf "\nCopy existing config.php file \n"
    cp ${oldocpath}/config/config.php ${ocpath}/config/config.php
  else
    printf "Skip to copy old config.php, file not found: ${oldocpath}/config/config.php \n"
  fi
fi

printf "\nchmod files and directories excluding data and apps-external directory\n"

# check if there are files to chmod/chown available. If not, exiting.
# chmod
if [ ! "$(find $ocpath -maxdepth 1 -type f)" ]; then
  echo "Something is wrong. There are no files to chmod. Exiting."
  exit
fi

find -L ${ocpath} -path ${ocdata} -prune -o -path ${ocapps_external} -prune -o -type f -print0 | xargs -0 chmod $filmod
find -L ${ocpath} -path ${ocdata} -prune -o -path ${ocapps_external} -prune -o -type d -print0 | xargs -0 chmod $dirmod

# no error messages on empty directories
if [ "$chmdir" = "n" ] && [ "$uselinks" = "n" ]; then

  printf "chmod data and apps-external directory (mkdir) \n"

  if [ -n "$(ls -A $ocdata)" ]; then
    find ${ocdata}/ -type f -print0 | xargs -0 chmod $filemod
  fi
  find ${ocdata}/ -type d -print0 | xargs -0 chmod $dirmod
  if [ -n "$(ls -A $ocapps_external)" ]; then
    find ${ocapps_external}/ -type f -print0 | xargs -0 chmod $filemod
  fi
  find ${ocapps_external}/ -type d -print0 | xargs -0 chmod $dirmod
fi

if [ "$chmdir" = "y" ] && [ "$uselinks" = "y" ]; then

  printf "chmod data and apps-external directory (linked) \n"

  if [ -n "$(ls -A $ocdata)" ]; then
    find -L ${ocdata}/ -type f -print0 | xargs -0 chmod $filmod
  fi
  find -L ${ocdata}/ -type d -print0 | xargs -0 chmod $dirmod
  if [ -n "$(ls -A $ocapps_external)" ]; then
    find -L ${ocapps_external}/ -type f -print0 | xargs -0 chmod $filmod
  fi
  find -L ${ocapps_external}/ -type d -print0 | xargs -0 chmod $dirmod
fi

#chown
printf "chown files and directories excluding data and apps-external directory \n"

find  -L $ocpath  -path ${ocdata} -prune -o -path ${ocapps_external} -prune -o -type d -print0 | xargs -0 chown ${rootuser}:${htgroup}
find  -L $ocpath  -path ${ocdata} -prune -o -path ${ocapps_external} -prune -o -type f -print0 | xargs -0 chown ${rootuser}:${htgroup}

# do only if directories are present
if [ -d ${ocpath}/apps/ ]; then
  printf "chown apps directory \n"
  chown -R ${htuser}:${htgroup} ${ocpath}/apps/
fi
if [ -d ${ocpath}/config/ ]; then
  printf "chown config directory \n"
  chown -R ${htuser}:${htgroup} ${ocpath}/config/
fi
if [ -d ${ocpath}/updater/ ]; then
  printf "chown updater directory \n"
  chown -R ${htuser}:${htgroup} ${ocpath}/updater
fi

if [ "$chmdir" = "n" ] && [ "$uselinks" = "n" ]; then
  printf "chown data and apps-external directories (mkdir) \n"
  chown -R ${htuser}:${htgroup} ${ocapps_external}/
  chown -R ${htuser}:${htgroup} ${ocdata}/
fi
if [ "$chmdir" = "y" ] && [ "$uselinks" = "y" ]; then
  printf "chown data and apps-external directories (linked) \n"
  chown -R ${htuser}:${htgroup} ${ocapps_external}/
  chown -R ${htuser}:${htgroup} ${ocdata}/
fi

printf "\nchmod occ command to make it executable \n"
if [ -f ${ocpath}/occ ]; then
  chmod +x ${ocpath}/occ
fi


# tell to remove the old instance, do upgrade and end maintenance mode ect.
printf "\nSUCCESS\n\n"
if [ "$do_upgrade" = "y" ]; then
  echo "Please manually run: sudo -u$htuser ./occ upgrade"
  echo "Please manually run: sudo -u$htuser ./occ maintenance:mode --off"
  echo "Please manually remove the directory of the old instance: $oldocpath"
  echo "When successfully done, re-run this script to secure your .htaccess files"
  echo
  if [ "$uselinks" = "n" ]; then
    echo "Please move/copy your data and apps-external directory manually back to the original location BEFORE running the upgrade command !"
    echo
  fi
fi

if [ "$do_new" = "y" ]; then
  echo "Open your browser, configure your instance and rerun this script to secure your .htaccess files"
  echo
fi
