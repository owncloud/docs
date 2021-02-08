#!/bin/bash

##
## Variable Declaration
##
base_uri={oc-examples-server-url}
API_PATH=ocs/v1.php/apps/files_sharing/api/v1

curl -X POST \
    --user {oc-examples-username}:{oc-examples-password} \
    "$base_uri/$API_PATH/shares/pending/<share_id>"
