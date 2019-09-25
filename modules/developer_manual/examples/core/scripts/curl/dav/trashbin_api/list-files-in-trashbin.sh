#!/usr/bin/env bash

##
## Variable Declaration
##
USERNAME={oc-examples-username}
PASSWORD={oc-examples-password}
API_PATH="remote.php/dav/trash-bin/<username>"
SERVER_URI="{oc-examples-server-url}"
REQUEST_BODY=$(cat <<EOF 
<?xml version="1.0"?>
<d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns">
    <d:prop>
        <oc:trashbin-original-filename />
        <oc:trashbin-original-location />
        <oc:trashbin-delete-datetime />
        <d:getcontentlength />
        <d:resourcetype />
    </d:prop>
</d:propfind>
EOF
)

curl '$SERVER_URI/$API_PATH/' \
  -H 'Content-Type: application/xml; charset=UTF-8' \
  -H 'Depth: 1' \
  -X PROPFIND \
  --data-binary "${REQUEST_BODY}" \
  --user "${USERNAME}:${PASSWORD}"
