#!/bin/bash
# export makes the variable available for all subprocesses

LE_PATH="/usr/bin"
LE_CB="certbot"

# Assumes that example.com www.example.com and subomain.example.com are the domains 
# that you want a certificate for
export DOMAINS="-d example.com -d www.example.com -d subdomain.example.com"

"$LE_PATH/$LE_CB" certonly --config /etc/letsencrypt/cli.ini "$DOMAINS" # --dry-run
