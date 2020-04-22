FILE="/etc/apache2/sites-available/owncloud.conf"
sudo /bin/cat <<EOM >$FILE
Alias /owncloud "{install-directory}/"

<Directory {install-directory}/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME {install-directory}
 SetEnv HTTP_HOME {install-directory}
</Directory>
EOM
