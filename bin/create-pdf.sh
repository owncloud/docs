#!/bin/bash

# This script is designed to simplify the process of generating PDFs from the
# Antora documentation. It's not written, yet, in a very defensive way, so all
# the required variables need to be passed, in the correct order, and in the
# correct format.

ERR_WRONG_ARGS=85
EXPECTED_ARG_COUNT=4
script_parameters=""

if [ $# -ne $EXPECTED_ARG_COUNT ]
then
    echo "Usage: `basename $0` $script_parameters"
    exit $ERR_WRONG_ARGS
fi

styles_directory="resources/themes"
style="owncloud"
fonts_directory="fonts"
manual="$1"
version="$2"
revision_date="$3"
output_path="$4"
input_file="books/catfile.$$.adoc"

case "$manual" in
    admin) 
        source_file=books/ownCloud_Admin_Manual.adoc 
        ;;
    developer) 
        source_file=books/ownCloud_Developer_Manual.adoc 
        ;;
    user) 
        source_file=books/ownCloud_User_Manual.adoc 
        ;;
esac

manual_infix="$(tr '[:lower:]' '[:upper:]' <<< ${manual:0:1})${manual:1}"

# Read the source file and concatenate the Antora navigation source
cat ${source_file} \
    <(php bin/create-pdf.php <modules/${manual}_manual/nav.adoc) \
    > ${input_file}

# Generate the PDF file
asciidoctor-pdf -d book \
    -a pdf-stylesdir="${styles_directory}/" \
    -a pdf-fontsdir="${fonts_directory}" \
    -a pdf-style="${style}" \
    -a examplesdir="$(pwd)/modules/${manual}_manual/examples/" \
    -a imagesdir="$(pwd)/modules/${manual}_manual/assets/images/" \
    -a partialsdir="$(pwd)/modules/${manual}_manual/pages/_partials/" \
    -a revnumber="${version}" \
    -a revdate="${revision_date}" \
    --base-dir "$(pwd)" \
    --out-file "${output_path}/ownCloud_"${manual_infix}"_Manual.pdf" \
    ${input_file}

# Remove the source file
rm ${input_file}
