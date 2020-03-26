# Add ownCloud’s repository to the list of available Zypper repositories
zypper addrepo --check --refresh --name "owncloud-repo" \
    https://download.owncloud.org/download/repositories/production/SLE_15/ \
    "Owncloudrepo"

# Optionally, check the status of the ownCloud repository
# zypper lr | grep -i owncloud

# Install the required packages
zypper update
zypper install --no-confirm \
    apache2-mod_php7 \
    owncloud-files \
    php7 \
    php7-bz2 \
    php7-curl \
    php7-gd \
    php7-imagick \
    php7-intl \
    php7-mbstring \
    php7-mysql \
    php7-sqlite \
    php7-zip

# Configure Apache for ownCloud
cp /usr/share/lib/owncloud-files-10.4.0/owncloud-config-apache.conf.default /etc/apache2/vhosts.d/owncloud.conf

# Restart Apache
apache2ctl -k graceful

# View the new site in Firefox
firefox http://localhost/owncloud

