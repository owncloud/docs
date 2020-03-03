# Retrieve the session save path setting (default or explicit value) for PHP {recommended-php-version} 
# Please change the file path to match your server configuration
session_path=$(\
    awk 'match($0, /^;?session.save_path = "(.*)"/, a) { print a[1] }' \
    /etc/php/{recommended-php-version}/**/php.ini \
    | uniq )

# Set the session save path in /etc/fstab
echo "tmpfs ${session_path} tmpfs defaults,noatime,mode=1777 0 0" >> /etc/fstab
