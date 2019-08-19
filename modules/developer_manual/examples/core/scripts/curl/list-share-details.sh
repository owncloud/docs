#!/bin/bash

##
## Variable Declaration
##
SERVER_URI={oc-examples-server-url}
API_PATH=ocs/v1.php/apps/files_sharing/api/v1

curl --user {oc-examples-username}:{oc-examples-password} \
    "$SERVER_URI/$API_PATH/shares?path=/Photos/Paris.jpg&reshares=true"
