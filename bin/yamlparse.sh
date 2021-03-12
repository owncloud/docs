#!/usr/bin/env bash
# shellcheck disable=SC1003

# Based on the work of https://gist.github.com/pkuczynski/8665367
# Source Reference: https://github.com/jasperes/bash-yaml

# Two lines have been changed compared to the source to adopt for special needs

# See the yamltest.sh script to get a testoutput, created to exctract asciidoc attributes 

parse_yaml() {
    local yaml_file=$1
    # the following line has been changed to avoid: "line 9: $2: unbound variable"
    local prefix="${2:-""}"   # was local prefix=$2
    local s
    local w
    local fs

    s='[[:space:]]*'
    w='[a-zA-Z0-9_.-]*'
    fs="$(echo @|tr @ '\034')"

    (
        sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |

        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
            -e 's/\$/\\\$/g' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

        awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1], $3);
                }
            }' |

        sed -e 's/_=/+=/g' |

        awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                 # The following line has been commented out as it would substitute
                 # dashes "-" with underscores "_" in keys, making them not identical/unusable.
                 # Example: supported-php-versions --> supported_php_versions
#                gsub("-|\\.", "_", $1)
            }
            { print }'
    ) < "$yaml_file"
}

unset_variables() {
  # Pulls out the variable names and unsets them.
  local variable_string="$@"
  unset variables
  variables=()
  for variable in ${variable_string[@]}; do
    variables+=($(echo $variable | grep '=' | sed 's/=.*//' | sed 's/+.*//'))
  done
  for variable in ${variables[@]}; do
    unset $variable
  done
}

create_variables() {
    local yaml_file="$1"
    local prefix="$2"
    local yaml_string="$(parse_yaml "$yaml_file" "$prefix")"
    unset_variables ${yaml_string[@]}
    eval "${yaml_string}"
}

