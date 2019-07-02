#!/bin/bash

set -o noclobber
set -o errexit
set -o pipefail
set -o nounset

FONTS_DIRECTORY="fonts"
RELEASE_DATE=$(date +'%B %d, %Y')
STYLE="owncloud"
STYLES_DIRECTORY="resources/themes"

ERR_UNSUPPORTED_LANGUAGE=20
ERR_UNSUPPORTED_MANUAL=21
ERR_UNSUPPORTED_ACTION=22

if [[ -z $VERSION ]]; then
    if [[ -n $DRONE_TAG ]]; then
        VERSION=${DRONE_TAG/v//}
    else
        [[ -n $DRONE_BRANCH ]] && VERSION=${DRONE_BRANCH/v//} || VERSION=master
    fi
fi

function usage()
{
    echo "Usage: cmd [-c] [-b <admin|developer|user>] [-v <go|xml|json|php|kotlin|yaml>] -r <revision> -d <release date>"
}

function clean_build_dir()
{
    echo "Cleaning build directory..."
    rm -rvf "build/"
    echo "...build directory cleaned."
}

function validate_code_files()
{
    language="$1"

    case $language in
        go)
            command -v golint &>/dev/null && \
                echo "Validating go source files" && \
                find . -type f -name "*.go" \
                    ! -path "./node_modules/*" \
                    ! -path "**/vendor/*" \
                    ! -path "./.git/*" \
                    -exec sh -c 'echo Linting {} && golint {} && echo' \;
            ;;

        json)
            command -v jsonlint &>/dev/null && \
                find . -type f -name "*.json" \
                    ! -path "./node_modules/*" \
                    ! -path "**/vendor/*" \
                    ! -path "./.git/*" \
                    -exec sh -c 'echo Linting {} && jsonlint -qp {} && echo' \;
            ;;

        kotlin)
            command -v ktlint &>/dev/null && \
                ktlint --reporter=plain "./modules/*_manual/**/*.kt" || true;
            ;;

        php)
            command -v php &>/dev/null && \
                find ./modules/*_manual/examples -type f -name "*.php" -exec php -l {} \;
            ;;

        xml)
            command -v xmllint &>/dev/null && \
                find ./modules/*_manual/examples -type f -name "*.xml" -exec xmllint --noout {} \;
            ;;

        yaml)
            command -v yamllint &>/dev/null && \
                find . -type f -name "*.yml" \
                    ! -path "./node_modules/*" \
                    ! -path "**/vendor/*" \
                    ! -path "./.git/*" \
                    -exec sh -c 'echo Linting {} && yamllint -f parsable {} && echo' \;
            ;;

        *)
            echo "That language is not, currently, supported" 
            exit $ERR_UNSUPPORTED_LANGUAGE
            ;;
    esac
}

function convert_antora_nav_to_asciidoc_list()
{
    filename="$1"

    while read line 
    do
        if [[ ${line} =~ \]$ ]]; then 
            level_offset=$(echo "$line" | awk -F"*" '{print NF-1}')
            revised_line=$(echo "$line" | sed 's/xref:/include::{module_base_path}/' | sed 's/\[.*\]//g' | sed -r 's/^\*{1,} //')
            echo "${revised_line}[leveloffset=+${level_offset}]"
        fi
    done < "${filename}"
}

function build_pdf_manual()
{
    manual="$1"
    release_date="$2"
    revision="$3"
    build_directory="$(pwd)/build/server/${revision}/${manual}_manual/"
    manual_infix="$(tr '[:lower:]' '[:upper:]' <<< ${manual:0:1})${manual:1}"
    book_file="books/ownCloud_${manual_infix}_Manual.adoc" 
    nav_file="modules/${manual}_manual/nav.adoc"
    input_file="books/catfile.$$.adoc"

    if [[ $manual != "admin" && $manual != "developer" && $manual != "user" ]]; then
        echo "That is not a valid manual" 
        exit $ERR_UNSUPPORTED_MANUAL
    fi

    echo "Generating version '${revision}' of the ${manual} manual, dated: ${release_date}"

    [[ ! -e "$build_directory" ]] && mkdir -p "$build_directory"

    asciidoctor-pdf -d book \
        -a pdf-stylesdir="${STYLES_DIRECTORY}/" \
        -a pdf-fontsdir="${FONTS_DIRECTORY}" \
        -a pdf-style="${STYLE}" \
        -a examplesdir="$(pwd)/modules/${manual}_manual/examples/" \
        -a imagesdir="$(pwd)/modules/${manual}_manual/assets/images/" \
        -a partialsdir="$(pwd)/modules/${manual}_manual/pages/_partials/" \
        -a revnumber="${revision}" \
        -a revdate="${release_date}" \
        --base-dir "$(pwd)" \
        --out-file "$(pwd)/build/server/${revision}/${manual}_manual/ownCloud_"${manual_infix}"_Manual.pdf" \
        <(cat $book_file <(convert_antora_nav_to_asciidoc_list "$nav_file"))
}

while getopts ":ucmvl:" o; do
    case "${o}" in
        m)
            ACTION="BUILD_MANUALS"
            ;;
        v)
            ACTION="VALIDATE"
            ;;
        l)
            language=${OPTARG}
            ;;
        c)
            ACTION="CLEAN"
            ;;
        u|*)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

case "$ACTION" in 
    BUILD_MANUALS) 
        build_pdf_manual "admin" "$RELEASE_DATE" "$VERSION"
        build_pdf_manual "developer" "$RELEASE_DATE" "$VERSION"
        build_pdf_manual "user" "$RELEASE_DATE" "$VERSION"
        ;;
    CLEAN) 
        clean_build_dir 
        ;;
    VALIDATE) 
        validate_code_files "$language" 
        ;;
    *)
        usage
        exit $ERR_UNSUPPORTED_ACTION
        ;;
esac
