#!/bin/bash

##
## Variable Declaration
##
base_uri={oc-examples-server-url}
API_PATH=ocs/v1.php/apps/files_sharing/api/v1

curl --user {oc-examples-username}:{oc-examples-password} \
     "$base_uri/$API_PATH/shares/115470" \
     --request PUT \
     --data 'expireDate=2017-01-02&name=paris%20photo'

