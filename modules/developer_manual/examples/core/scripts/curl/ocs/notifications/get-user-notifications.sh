#!/usr/bin/env bash

USERNAME=admin
PASSWORD={oc-examples-password}
API_PATH="ocs/v2.php/apps/notifications/api/v1/notifications"
SERVER_URI="{oc-examples-server-url}"

# Get response in XML format
curl '$SERVER_URI/$API_PATH/' \
  --user "${USERNAME}:${PASSWORD}"

# Get response in JSON format
curl '$SERVER_URI/$API_PATH?format=json' \
  --user "${USERNAME}:${PASSWORD}" | jq

