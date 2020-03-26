# Create the virtual host configuration directories
mkdir /etc/httpd/sites-available /etc/httpd/sites-enabled

FILE="/etc/httpd/sites-available/owncloud.conf"
sudo /bin/cat <<EOM >$FILE
Alias /owncloud "{install-directory}"

<Directory {install-directory}>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME {install-directory}
 SetEnv HTTP_HOME {install-directory}
</Directory>
EOM

# Enable the virtual host configuration
ln -s /etc/httpd/sites-available/owncloud.conf /etc/httpd/sites-enabled/owncloud.conf

# Add the virtual host configuration to Apache's main configuration file
echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
