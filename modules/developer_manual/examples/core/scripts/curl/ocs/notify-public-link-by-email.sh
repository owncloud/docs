#!/usr/bin/env bash

USERNAME={oc-examples-username}
PASSWORD={oc-examples-password}
API_PATH="ocs/v1.php/apps/files_sharing/api/v1/notification/notify-public-link-by-email"
SERVER_URI="{oc-examples-server-url}"

curl '$SERVER_URI/$API_PATH/' \
  -X POST \
  --data "recipients[]=user@example.com" \
  --data "link=${SERVER_URI}/index.php/s/sfU97LuwePm5omD" \
  --data "personalNote=A personal note." \
  --user "${USERNAME}:${PASSWORD}"

