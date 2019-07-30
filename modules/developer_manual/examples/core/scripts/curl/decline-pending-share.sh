#!/bin/bash

##
## Variable Declaration
##
SERVER_URI={oc-examples-server-url}
API_PATH=ocs/v1.php/apps/files_sharing/api/v1

curl -X DELETE \
    --user {oc-examples-username}:{oc-examples-password} \
    "$SERVER_URI/$API_PATH/shares/pending/<share_id>"
