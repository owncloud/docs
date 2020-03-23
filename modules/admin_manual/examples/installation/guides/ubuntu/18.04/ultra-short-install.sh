# Add ownCloud’s repository to the list of available Apt repositories
curl https://download.owncloud.org/download/repositories/production/{distribution-name}_{distribution-version}/Release.key \
  | apt-key add -
echo 'deb http://download.owncloud.org/download/repositories/production/{distribution-name}_{distribution-version}/ /' \
  > /etc/apt/sources.list.d/owncloud-files.list

# Install the required packages
apt update
apt install -y libapache2-mod-php owncloud-files php-bz2 php-curl \
  php-gd php-imagick php-intl php-mbstring php-mysql php-sqlite3 \
  php-xml php-zip

# Configure Apache for ownCloud
cp /usr/share/doc/owncloud-files/owncloud-config-apache.conf.default /etc/apache2/conf-available/owncloud-config-apache.conf
a2enconf owncloud-config-apache
a2enmod php7.2

# Restart Apache
systemctl reload apache2

# View the new site in Firefox
firefox http://localhost/owncloud

