#!/bin/bash

#Récupération des variables du fichier yaml avec le script de stefan

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


eval "$(parse_yaml /path/to/conf.yaml "CONF_")"


# creation of the variable name according to the environment

ENV="dev"

CONF_AMTREE_VAR=CONF_${ENV}__PATHAMTREE
declare PATHAMTREE=$CONF_AMTREE_VAR

CONF_URL_VAR=CONF_${ENV}__urlAM
declare urlAM=$CONF_URL_VAR

CONF_LOGIN_VAR=CONF_${ENV}__Login
declare Login=$CONF_LOGIN_VAR

CONF_PASSWORD_VAR=CONF_${ENV}__amadminPassword
declare amadminPassword=$CONF_PASSWORD_VAR

CONF_REALM_VAR=CONF_${ENV}__Realm
declare Realm=$CONF_REALM_VAR

"${!PATHAMTREE}" -s -r "${!Realm}" -h "${!urlAM}" -u "${!Login}" -p "${!amadminPassword}"
