#!/bin/bash

APPS_LIST=$(sudo -u www-data ./occ app:list --shipped=false --output=json)
APP_DIR="apps"
CUSTOM_APP_DIR="apps-external"
JQ_INSTALLED=$(command -v jq)

if [ -z $JQ_INSTALLED ]; then
    echo "Sorry, you need to install jq to run this script."
    echo "Install it with your package manager, or visit https://stedolan.github.io/jq/."
    exit -1
fi

if [ -z $APPS_LIST ]; then
    echo "No apps available for moving."
    echo "Exiting."
    exit 0
fi

if [ ! -d "$CUSTOM_APP_DIR" ]; then
    echo "Custom app directory does not exist."
    echo "Exiting."
    exit 0
fi

for app in $(echo $APPS_LIST | jq '.enabled, .disabled' | jq -r 'keys[]'); do
    if [ -d "$APP_DIR/${app}" ]; then
        echo "Moving $APP_DIR/${app} to $CUSTOM_APP_DIR/${app}."
        sudo -u www-data mv "$APP_DIR/${app}" "$CUSTOM_APP_DIR/${app}" \
            && echo "Directory moved."
        echo 
    fi;
done
