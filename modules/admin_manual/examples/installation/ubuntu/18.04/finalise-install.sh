FILE="/usr/local/bin/ocpermissions"

/bin/cat <<EOM >$FILE
#!/bin/bash 

ocpath="{install-directory}" 
datadir="${ocpath}/data" 
htuser="{webserver-user}" 
htgroup="{webserver-group}" 
rootuser="root" 

printf "Creating any missing directories" 
sudo -u "${htuser}" mkdir -p "${ocpath}/assets" 
sudo -u "${htuser}" mkdir -p "${ocpath}/updater" 
sudo -u "${htuser}" mkdir -p "${datadir}" 

printf "Update file and directory permissions" 
sudo find "${ocpath}/" -type f -print0 | xargs -0 chmod 0640 
sudo find "${ocpath}/" -type d -print0 | xargs -0 chmod 0750 

printf "Set web server user and group as ownCloud directory user and group" 
sudo chown -R "${rootuser}:${htgroup}" "${ocpath}/" 
sudo chown -R "${htuser}:${htgroup}" "${ocpath}/apps/" 
sudo chown -R "${htuser}:${htgroup}" "${ocpath}/apps-external/" 
sudo chown -R "${htuser}:${htgroup}" "${ocpath}/assets/" 
sudo chown -R "${htuser}:${htgroup}" "${ocpath}/config/" 
sudo chown -R "${htuser}:${htgroup}" "${datadir}" 
sudo chown -R "${htuser}:${htgroup}" "${ocpath}/updater/" 
sudo chmod +x "${ocpath}/occ"

printf "Set web server user and group as .htaccess user and group" 
if [ -f "${ocpath}/.htaccess" ]; then  
  sudo chmod 0644 "${ocpath}/.htaccess"  
  sudo chown "${rootuser}:${htgroup}" "${ocpath}/.htaccess" 
fi 

if [ -f "${datadir}/.htaccess" ]; then  
  sudo chmod 0644 "${datadir}/.htaccess"  
  sudo chown "${rootuser}:${htgroup}" "${datadir}/.htaccess"
fi 

EOM

# Make the script executable
sudo chmod +x ${FILE}

${FILE}
