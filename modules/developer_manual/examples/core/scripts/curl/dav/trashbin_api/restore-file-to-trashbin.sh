#!/bin/bash

##
## Variable Declaration
##
USERNAME={oc-examples-username}
PASSWORD={oc-examples-password}
API_PATH="remote.php/dav/trash-bin/${USERNAME}/${FILE_ID}"
SERVER_URI="{oc-examples-server-url}"

curl '$SERVER_URI/$API_PATH/' \
  -H 'Overwrite: F' \
  -H 'Destination: ${SERVER_URI}/remote.php/dav/files/${USERNAME}/<filepath>' \
  -X MOVE \
  --user "${USERNAME}:${PASSWORD}"
