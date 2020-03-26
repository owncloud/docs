yum install --assumeyes \
  bzip2 \
  coreutils \
  curl \
  gcc \
  jq \
  libsmbclient-devel \
  omping \
  openssh \
  php-devel \
  php-ldap \
  php-pear \
  rsync \
  samba-client

# Install Pear and PECL
pecl channel-update pecl.php.net & \
    pear update-channels & \
    pear upgrade pear

# Install PHP's smbclient extension
pecl install smbclient

# Install jq
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
cp jq /usr/bin
