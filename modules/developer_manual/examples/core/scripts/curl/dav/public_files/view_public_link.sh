#!/usr/bin/env bash

##
## Variable Declaration
##
API_PATH="/remote.php/dav/public-files/<share_token>"
SERVER_URI="{oc-examples-server-url}"
REQUEST_BODY=$(cat <<EOF                                                                
<?xml version="1.0"?>                                 
<d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns">
    <d:prop>   
        <oc:public-link-item-type />
        <oc:public-link-item-permission />
        <oc:public-link-item-expiration />
        <oc:public-link-item-share-datetime />
        <oc:public-link-item-owner />
    </d:prop>
</d:propfind>
EOF
)

curl "'$SERVER_URI/$API_PATH" \
    -H 'Content-Type: application/xml; charset=UTF-8' \
    -H 'Depth: 1' \
    -X PROPFIND \
    --data-binary "${REQUEST_BODY}"
