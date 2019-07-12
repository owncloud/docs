FILE="/etc/logrotate.d/owncloud"
sudo /bin/cat <<EOM >$FILE
{install-directory}/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM
