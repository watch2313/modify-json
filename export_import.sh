#!/bin/bash

ENV=$1
FUNCTION=$2

#We need the parse_yaml.sh script wich contains the function that parses the yaml files
source /path/to/parse_yaml.sh

#Retrieving variables from the yaml file
#Read the yaml file, the function is in the parse_yaml.sh script
eval "$(parse_yaml /path/to/conf1.yaml "CONF_")"


#creation of the variable name according to the environment


CONF_AMTREE_VAR=CONF_${ENV}_PATHAMTREE
declare PATHAMTREE=$CONF_AMTREE_VAR

CONF_URL_VAR=CONF_${ENV}_urlAM
declare urlAM=$CONF_URL_VAR

CONF_LOGIN_VAR=CONF_${ENV}_Login
declare Login=$CONF_LOGIN_VAR

CONF_PASSWORD_VAR=CONF_${ENV}_amadminPassword
declare amadminPassword=$CONF_PASSWORD_VAR

CONF_REALM_VAR=CONF_${ENV}_Realm
declare Realm=$CONF_REALM_VAR

if [ "$FUNCTION" == "export" ]; then
    #Run the command to export authentication trees from vscheuber script
    "${!PATHAMTREE}" -S -r "${!Realm}" -h "${!urlAM}" -u "${!Login}" -p "${!amadminPassword}"
    
elif [ "$FUNCTION" == "import" ]; then
     #Run the command to import authentication trees from vscheuber script
    "${!PATHAMTREE}" -s -r "${!Realm}" -h "${!urlAM}" -u "${!Login}" -p "${!amadminPassword}"
    
else 
     exit
fi 
    
