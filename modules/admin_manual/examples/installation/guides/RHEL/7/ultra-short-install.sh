# Add ownCloud’s repository to the list of available Yum repositories
curl -q 'https://download.owncloud.org/download/repositories/production/RHEL_7/ce:stable.repo' \
> /etc/yum.repos.d/owncloud-files.repo
# Update the repo name
sed -i 's/ce_production/owncloud_files/g' /etc/yum.repos.d/owncloud-files.repo

# Optionally check that the repo is configured and what its settings are
# yum-config-manager owncloud_files

# Make the latest PHP versions available to YUM
yum install epel-release -y & \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# Install the required packages
yum --enablerepo=remi-php{minimum-php-version-short-code} install --assumeyes httpd \
    owncloud-files \
    php{minimum-php-version-short-code}-php-curl \
    php{minimum-php-version-short-code}-php-gd \
    php{minimum-php-version-short-code}-php-intl \
    php{minimum-php-version-short-code}-php-mbstring \
    php{minimum-php-version-short-code}-php-pecl-apcu \
    php{minimum-php-version-short-code}-php-pecl-imagick \
    php{minimum-php-version-short-code}-php-pecl-mysql \
    php{minimum-php-version-short-code}-php-pecl-zip \
    php{minimum-php-version-short-code}-php-sqlite3 \
    php{minimum-php-version-short-code}-php-xml

# Create the virtual host configuration directories
mkdir /etc/httpd/sites-available /etc/httpd/sites-enabled

# Configure Apache for ownCloud
cp /usr/share/lib/owncloud-files-10.4.0/owncloud-config-apache.conf.default /etc/httpd/sites-available/owncloud.conf

# Enable the virtual host configuration
ln -s /etc/httpd/sites-available/owncloud.conf /etc/httpd/sites-enabled/owncloud.conf

# Add the virtual host configuration to Apache's main configuration file
echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf

# Restart Apache
apache2ctl -k graceful

# View the new site in Firefox
firefox http://localhost/owncloud
