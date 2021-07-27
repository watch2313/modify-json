#!/bin/bash

#1) retrieving command line arguments in variables
FILE=$1
ENV=$2
KEY=$3

#We need the parse_yaml.sh script wich contains the function that parses the yaml files
source /path/to/parse_yaml.sh

#2) check that there is the right number of arguments
if [ $# -ne 3 ]; then
     echo "Incorrect number of arguments, syntax $0 "FILE" "ENV" "KEY""
     exit
fi

#3) check that the file exists
   if [! -f "$FILE" ]; then
       echo "The file $FILE does not exist"
   fi

#4) Reading the yaml file
eval "$(parse_yaml $FILE "CONF1_")"

#5) retrieve of the value of ENV.KEY
secretvalue=CONF1_${ENV}_$KEY
