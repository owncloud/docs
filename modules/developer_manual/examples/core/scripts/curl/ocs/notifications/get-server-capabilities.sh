#!/usr/bin/env bash

USERNAME=admin
PASSWORD={oc-examples-password}
API_PATH="ocs/v2.php/cloud/capabilities"
SERVER_URI="{oc-examples-server-url}"

# Get server capabilities in XML format
curl '$SERVER_URI/$API_PATH/' \
  --user "${USERNAME}:${PASSWORD}"

# Get server capabilities in JSON format
curl '$SERVER_URI/$API_PATH?format=json' \
  --user "${USERNAME}:${PASSWORD}" | jq
