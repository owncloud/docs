# Make the latest PHP versions available to YUM
yum install epel-release -y & \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

yum --enablerepo=remi-php{minimum-php-version-short-code} install --assumeyes \
  httpd \
  mariadb-server \
  openssl \
  php{minimum-php-version-short-code} \
  php{minimum-php-version-short-code}-php-gd \
  php{minimum-php-version-short-code}-php-imap \
  php{minimum-php-version-short-code}-php-intl \
  php{minimum-php-version-short-code}-php-json \
  php{minimum-php-version-short-code}-php-mbstring \
  php{minimum-php-version-short-code}-php-pecl-apcu \
  php{minimum-php-version-short-code}-php-pecl-imagick \
  php{minimum-php-version-short-code}-php-pecl-mysql \
  php{minimum-php-version-short-code}-php-pecl-redis5 \
  php{minimum-php-version-short-code}-php-pecl-ssh2 \
  php{minimum-php-version-short-code}-php-pecl-zip \
  php{minimum-php-version-short-code}-php-xml \
  redis \
  wget
