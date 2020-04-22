FILE="/usr/local/bin/ocpermissions"

/bin/cat <<EOM >$FILE
#!/bin/bash

ocpath="/var/www/owncloud"
datadir="${ocpath}/data"
htuser="www-data"
htgroup="www-data"

printf "Running ${0}"
echo

echo "Creating any missing directories."
sudo -u "${htuser}" mkdir -p "${ocpath}/assets"
sudo -u "${htuser}" mkdir -p "${ocpath}/updater"
sudo -u "${htuser}" mkdir -p "${datadir}"

echo "Updating file and directory permissions."
sudo find "${ocpath}/" -type f -print0 | xargs -0 chmod 0644
sudo find "${ocpath}/" -type d -print0 | xargs -0 chmod 0754

# Directories to update permissions on
directories=(
  "${ocpath}/" 
  "${ocpath}/apps/" 
  "${ocpath}/apps-external/" 
  "${ocpath}/assets/" 
  "${ocpath}/config/" 
  "${datadir}/" 
  "${ocpath}/updater/" 
)
set_dir_ownership_and_permissions() {
  if [ -e "$1" ] && [ -d "$1" ]; then
    path="${1}"
    printf "Setting owner of \"%s\" to \"%s\" and group to \"%s\"\n" "${path}" "${htuser}" "${htgroup}"
    sudo chown -R "${htuser}:${htgroup}" "${path}"
  fi;
}

for directory in "${directories[@]}"
do
  set_dir_ownership_and_permissions "${directory}"
done;
sudo chmod +x "${ocpath}/occ"

echo "Setting web server user and group as .htaccess owner and group."
if [ -f "${ocpath}/.htaccess" ]; then
  sudo chmod 0664 "${ocpath}/.htaccess"
  sudo chown "${htuser}:${htgroup}" "${ocpath}/.htaccess"
fi

if [ -f "${datadir}/.htaccess" ]; then
  sudo chmod 0664 "${datadir}/.htaccess"
  sudo chown "${htuser}:${htgroup}" "${datadir}/.htaccess"
fi

echo "Exiting"
echo
EOM

# Make the script executable
sudo chmod +x ${FILE}

${FILE}