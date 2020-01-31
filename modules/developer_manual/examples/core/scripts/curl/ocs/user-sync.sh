#!/usr/bin/env bash

##
## Variable Declaration
##
USERNAME={oc-examples-username}
PASSWORD={oc-examples-password}
API_PATH="ocs/v2.php/cloud/user-sync/<userid>"
SERVER_URI="{oc-examples-server-url}"

curl '$SERVER_URI/$API_PATH/' \
  -H 'Content-Type: application/xml; charset=UTF-8' \
  -X POST \
  --user "${USERNAME}:${PASSWORD}"

