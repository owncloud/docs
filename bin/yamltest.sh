#!/usr/bin/env bash

source ./yamlparse.sh

echo
echo "Test-prints the found attributes of the ../site.yml file for docs for reuse in asciidoctor-pdf as arguments in a line by line formatted way to compare with the source yaml file"
echo

# Get key / value pair and preformat it (-a key=value -a key=value ...)
# This is form is used in asciidoctor-pdf
variable=$(parse_yaml ../site.yml | grep asciidoc_attributes | sed 's/asciidoc_attributes_/-a /g' | sed 's/\")/\" /' | sed 's/=(/=/' | sed "s/\"'/\'/" | sed "s/'\"/\'/")

# Show every -a key=value in a new line for ease of comparison with the original
echo "$variable" | awk -F'-a ' '{$1=$1}1' OFS='-a '
echo
