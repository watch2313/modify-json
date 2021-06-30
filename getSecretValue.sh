#!/bin/bash

#1) retrieving command line arguments in variables
FILE=$1
ENV=$2
KEY=$3

#2) check that there is the right number of arguments
if [ $# -ne 3 ]; then
     echo "Incorrect number of arguments, syntax $0 "FILE" "ENV" "KEY""
     exit
fi

#3) check that the file exists
   if [! -f $FILE ]; then
       echo "The file "$FILE" does not exist"
   fi

#4) Reading the yaml file

function parse_yaml {
     local prefix=$2
     local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
     sed -ne "s|^\($s\):|\1|"  \
          -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
          -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
      awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
            if (length($3) > 0) {
              vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
              printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
         }
     }'
 }

eval "$(parse_yaml $FILE "CONF1_")"

#5) retrieve of the value of ENV.KEY
secretvalue=CONF1_${ENV}_$KEY
