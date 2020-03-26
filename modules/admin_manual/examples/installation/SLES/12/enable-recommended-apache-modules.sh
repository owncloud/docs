echo "Enabling Apache Modules"
a2enmod dir env headers mime rewrite setenvif

echo "Restarting Apache"
apache2ctl -k graceful
