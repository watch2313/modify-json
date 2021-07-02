#!/bin/bash

ENV=$1
MODE=$2

#Retrieving variables from the yaml file
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
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

if [ "$MODE" == "import" ]; then
    #Run the command to import authentication trees from vscheuber script
    "${!PATHAMTREE}" -s -r "${!Realm}" -h "${!urlAM}" -u "${!Login}" -p "${!amadminPassword}"
    
elif [ "$MODE" == "export" ]; then
     #Run the command to export authentication trees from vscheuber script
    "${!PATHAMTREE}" -S -r "${!Realm}" -h "${!urlAM}" -u "${!Login}" -p "${!amadminPassword}"
    
else 
     exit
fi 
    
