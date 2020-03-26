echo "Enabling Apache Modules"

a2enmod dir env headers mime rewrite setenvif
service apache2 reload
