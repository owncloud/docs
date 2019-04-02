#!/bin/bash

# To setup this script for your environment, adopt the following variables to your needs:
#
# ocname	the name of your directory containing the owncloud files
# ocroot	the path to ocname, usually /var/www (no trailing slash)
# linkroot	the path to your source directory for linking data and apps-external (no trailing slash)
# htuser	the webserver user
# htgroup	the webserver group
# rootuser	the root user

# Short description for paramters used in find
#
# -L       ... Follow symbolic links. Needed in case if links are used or present
# -path    ... The path to process
# -prune   ... If the file is a directory, do not descend into it (used to exclude directories)
# -o       ... OR (to add more parameters)
# -type    ... File is of type [d ... directory, f ... file]
# -print0  ... Print the full file name on the standard output, followed by a null character
# xargs -0 ... Reads items from the standard input, input items are terminated by a null character


ocname='owncloud'
ocroot='/var/www'
ocpath=$ocroot/$ocname
ocdata=$ocroot/$ocname/'data'
ocapps_external=$ocpath/'apps-external'
oldocpath=$ocroot/$ocname'_'$(date +%F-%H.%M.%S)

linkroot='/var/mylinks'
linkdata=$linkroot/'data'
linkapps_external=$linkroot/'apps-external'

htuser='www-data'
htgroup='www-data'
rootuser='root'

# Because the data directory can be huge or on external storage, an automatic chmod/chown can take a while.
# Therefore this directory can be treated differently.
# If you have already created an external data and apps-external directory which you want to link,
# set the paths above accordingly. This script can link and set the proper rights and permissions
# depending what you enter when running the script.
# You have to run this script twice, one time to prepare installation and one time post installation

# In case you upgrade an existing installation, your original directory will be renamed including a timestamp 

# Example input
# New install using mkdir:     n/n/n/n (create missing directories, setup permissions and ownership)
# Upgrade using mkdir:         y/n/n/n (you move/replace data, apps-external and config.php manually, set setup permissions and ownership)
# New install using links:     n/y/y/n (link existing directories, setup permissions and ownership)
# Upgrade using links:         y/y/n/y (link existing directories, copy config.php, permissions and ownership are already ok)
# Post installation/upgrade:   either n/n/n/n or n/y/y/n
# Reset all perm & own:        either n/n/n/n or n/y/y/n

echo
read -p "Do you want to upgrade an existing installation (y/N)? " -r -e answer
(echo "$answer" | grep -iq "^y") && do_upgrade="y" || do_upgrade="n"

read -p "Do you want to use ln instead of mkdir for creating directories (y/N)? " -r -e answer
(echo "$answer" | grep -iq "^y") && uselinks="y" || uselinks="n"

read -p "Do you also want to chmod/chown these links (y/N)? " -r -e answer
(echo "$answer" | grep -iq "^y") && chmdir="y" || chmdir="n"

if [ "$do_upgrade" = "y" ]; then
  read -p "Do you want to copy an existing config.php file (y/N)? " -r -e answer
  (echo "$answer" | grep -iq "^y") && upgrdcfg="y" || upgrdcfg="n"
fi

# check if upgrading an existing installation
if [ "$do_upgrade" = "y" ]; then
  read -p "Is the instance in maintenance mode? (y/N)? " -r -e answer
  (echo "$answer" | grep -iq "^y") && mmode="y" || mmode="n"
  if [ "$mmode" = "n" ]; then
    echo "Please enable maintenance mode first: sudo -uwww-data ./occ maintenance:mode --on"
    echo
    exit
  fi

  read -p "Please specify the tar file to extract with full path: " -r -e answer
  if [ ! -f "$answer" ]; then
    echo "tar file to extract not found. Exiting."
    echo
    exit
  fi

  if [ -d ${ocpath} ]; then
    mv $ocpath $oldocpath
  fi

  mkdir -p $ocpath
  tar xvf "$answer" -C $ocpath --strip-components=1

  if [ $? != 0 ]; then
    echo
    echo "tar extract failed, please check !"
    echo
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
  if [ -d ${ocdata} ]; then
    echo "Directory for $ocdata found but link requested. Exiting."
    echo
    exit
  else
    printf "ln $ocdata \n"
    mkdir -p $linkdata
    ln -sfn $linkdata $ocdata
  fi
  if [ -d ${ocapps_external} ]; then
    echo "Directory for $ocapps_external found but link requested. Exiting."
    echo
    exit
  else
    printf "ln $ocapps_external \n"
    mkdir -p $linkapps_external
    ln -sfn $linkapps_external $ocapps_external
  fi
fi

# copy if requested an existing config.php
if [ "$upgrdcfg" = "y" ]; then
  if [ -f ${oldocpath}/config/config.php ]; then
    printf "\nCopy existing config.php file \n"
    cp ${oldocpath}/config/config.php ${ocpath}/config/config.php
  else
    printf "Skip to copy old config.php, file not found: ${oldocpath}/config/config.php \n"
  fi
fi

printf "\nchmod files and directories excluding data and apps-external directory \n"

# check if there are files to chmod/chown available. If not exiting.
# chmod
if [ ! "$(find $ocpath -maxdepth 1 -type f)" ]; then
  echo "Something is wrong. There are no files to chmod. Exiting."
  exit
fi

find -L ${ocpath} -path ${ocdata} -prune -o -path ${ocapps_external} -prune -o -type f -print0 | xargs -0 chmod 0640
find -L ${ocpath} -path ${ocdata} -prune -o -path ${ocapps_external} -prune -o -type d -print0 | xargs -0 chmod 0750

# no error messages on empty directories
if [ "$chmdir" = "n" ] && [ "$uselinks" = "n" ]; then

  printf "chmod data and apps-external directory (mkdir) \n"

  if [ -n "$(ls -A $ocdata)" ]; then
    find ${ocdata}/ -type f -print0 | xargs -0 chmod 0640
  fi
  find ${ocdata}/ -type d -print0 | xargs -0 chmod 0750
  if [ -n "$(ls -A $ocapps_external)" ]; then
    find ${ocapps_external}/ -type f -print0 | xargs -0 chmod 0640
  fi
  find ${ocapps_external}/ -type d -print0 | xargs -0 chmod 0750
fi

if [ "$chmdir" = "y" ] && [ "$uselinks" = "y" ]; then

  printf "chmod data and apps-external directory (linked) \n"

  if [ -n "$(ls -A $ocdata)" ]; then
    find -L ${ocdata}/ -type f -print0 | xargs -0 chmod 0640
  fi
  find -L ${ocdata}/ -type d -print0 | xargs -0 chmod 0750
  if [ -n "$(ls -A $ocapps_external)" ]; then
    find -L ${ocapps_external}/ -type f -print0 | xargs -0 chmod 0640
  fi
  find -L ${ocapps_external}/ -type d -print0 | xargs -0 chmod 0750
fi

#chown
printf "\nchown files and directories excluding data and apps-external directory \n"

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

printf "chmod/chown .htaccess \n"
if [ -f ${ocpath}/.htaccess ]; then
  chmod 0644 ${ocpath}/.htaccess
  chown ${rootuser}:${htgroup} ${ocpath}/.htaccess
fi
if [ -f ${ocdata}/.htaccess ];then
  chmod 0644 ${ocdata}/.htaccess
  chown ${rootuser}:${htgroup} ${ocdata}/.htaccess
fi
echo

# tell to remove the old instance, do upgrade and end maintenance mode if all is fine
if [ "$do_upgrade" = "y" ]; then
  echo "Please manually remove the directory of the old instance: $oldocpath"
  echo "Please manually run: sudo -uwww-data ./occ upgrade"
  echo "Please manually run: sudo -uwww-data ./occ maintenance:mode --off"
  echo
fi
