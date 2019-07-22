#!/usr/bin/env bash

USERNAME=admin
PASSWORD={oc-examples-password}
API_PATH="ocs/v1.php/apps/twofactor_totp/api/v1/validate/<userid>/<totp>"
SERVER_URI="{oc-examples-server-url}"

curl '$SERVER_URI/$API_PATH/' \
  --user "${USERNAME}:${PASSWORD}"
