#!/bin/bash

set -o pipefail

GREEN='\033[0;32m'
NC='\033[0m' # No Color

s="smbclient.ini"
content="extension=smbclient.so"
v=$(php -r "echo PHP_VERSION;" | grep --only-matching --perl-regexp "7.\d+")
file="/etc/php/${v}/mods-available/${s}"

echo
echo -e "${GREEN}dismod and pecl/apt smbclient uninstall${NC}"
echo

if [[ -f "$FILE" ]]; then
    phpdismod smbclient
    echo '' | pecl uninstall smbclient
    apt purge smbclient
    apt autoremove
fi

echo
echo -e "${GREEN}bootstrap${NC}"
echo

../bootstrap.sh

echo
echo -e "${GREEN}compile${NC}"
echo

../compile_samba.sh

echo
echo -e "${GREEN}make${NC}"
echo

"$(make -j 4)"

echo
echo -e "${GREEN}install${NC}"
echo

"$(make install -j 4)"

echo
echo -e "${GREEN}install pecl smbclient${NC}"
echo

"$(pecl channel-update pecl.php.net)"
echo '' | pecl install smbclient

echo
echo -e "${GREEN}phpenmod${NC}"
echo

if [[ ! -f "$FILE" ]]; then
    echo "$content" > "$file"
    echo "Created ${file}"
fi

phpenmod smbclient
