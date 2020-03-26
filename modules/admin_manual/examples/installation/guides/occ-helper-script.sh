FILE="/usr/local/bin/occ"
/bin/cat <<EOM >$FILE
#! /bin/bash

cd {install-directory}
sudo -u {webserver-user} /usr/bin/php {install-directory}/occ "\$@"
EOM

