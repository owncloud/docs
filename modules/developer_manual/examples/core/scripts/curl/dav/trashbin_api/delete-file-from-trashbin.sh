#!/bin/bash

##
## Variable Declaration
##
FILE_ID=11111
USERNAME={oc-examples-username}
PASSWORD={oc-examples-password}
API_PATH="remote.php/dav/trash-bin/${USERNAME}/${FILE_ID}"
SERVER_URI="{oc-examples-server-url}"

curl '$SERVER_URI/$API_PATH/' \
  -X DELETE \
  --user "${USERNAME}:${PASSWORD}"
