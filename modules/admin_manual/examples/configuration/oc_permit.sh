#!/bin/bash

set -o pipefail
set -o errtrace
set -o nounset

# Please update the paths in the variables below to suit your installation.
htuser='settermjd'
htgroup='staff'
logfile='output.log'
ocpath=''
ocstorage=''
rootuser='root'

if [[ ! -e "$ocpath" ]] || [[ -z "$ocpath" ]] || [[ ! -e "$ocstorage" ]] || [[ -z "$ocstorage" ]]; then
    printf "Either one or both of the ownCloud root and data directories are missing.\n"
    printf "Please check that the values set for ocpath and ocstorage are correct before running the script.\n"
    printf "Exiting.\n"
    exit -1;
fi

if [[ ! -e "$ocstorage/data" ]]; then
    printf "Creating missing ownCloud data directory\n"
    mkdir -p $ocstorage/data
fi

printf "Updating file and directory permissions of the ownCloud directory\n"
find "${ocpath}/" -type f -print0 | xargs -0 chmod 0640 >> $logfile 2>&1
find "${ocpath}/" -type d -print0 | xargs -0 chmod 0750 >> $logfile 2>&1

printf "Updating owner of the ownCloud apps and config directories.\n"
chown -R "${rootuser}:${htgroup}" "${ocpath}/" >> $logfile 2>&1
if [ $? -ne 0 ]; then
    printf "  Unable to recursively set owner and group on [%s].\n" "${ocpath}/"
fi

chown -R "${htuser}:${htgroup}" "${ocpath}/apps/" >> $logfile 2>&1
if [ $? -ne 0 ]; then
    printf "  Unable to recursively set owner and group on [%s].\n" "${ocpath}/apps/"
fi

chown -R "${htuser}:${htgroup}" "${ocpath}/config/" >> $logfile 2>&1
if [ $? -ne 0 ]; then
    printf "  Unable to recursively set owner and group on [%s].\n" "${ocpath}/config/"
fi

printf "Updating ownCloud storage directory and file permissions.\n"
find "${ocstorage}/" -type f -print0 | xargs -0 chmod 0640 >> $logfile 2>&1
find "${ocstorage}/" -type d -print0 | xargs -0 chmod 0750 >> $logfile 2>&1

chmod +x "${ocpath}/occ"

printf "Updating .htaccess owner and permissions.\n"
if [ -f "${ocpath}/.htaccess" ]; then
  chmod 0644 "${ocpath}/.htaccess" >> $logfile 2>&1
  if [ $? -ne 0 ]; then
    printf "  Unable to set permissions on [%s].\n" "${ocpath}/.htaccess"
  fi

  chown "${rootuser}:${htgroup}" "${ocpath}/.htaccess" >> $logfile 2>&1
  if [ $? -ne 0 ]; then
    printf "  Unable to set owner and group on [%s].\n" "${ocpath}/.htaccess"
  fi
fi

if [ -f "${ocstorage}/data/.htaccess" ]; then
  chmod -f 0644 "${ocstorage}/data/.htaccess" >> $logfile 2>&1
  if [ $? -ne 0 ]; then
    printf "  Unable to set permissions on [%s].\n" "${ocstorage}/data/.htaccess"
  fi

  chown "${rootuser}:${htgroup}" "${ocstorage}/data/.htaccess" >> $logfile 2>&1
  if [ $? -ne 0 ]; then
    printf "  Unable to set owner and group on [%s].\n" "${ocstorage}/data/.htaccess"
  fi
fi

echo "Finished."
echo "Exiting."
