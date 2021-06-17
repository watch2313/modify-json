#!/bin/bash

#1) retrieving command line arguments in variables
YAML1=$1
YAML2=$2
ENV=$3
JSON=$4

#2) check that there is the right number of arguments
if [ $# -ne 4 ]; then
     echo "Incorrect number of arguments, syntax $0 "FILE" "ENV" "KEY""
     exit
fi

#3) check that the first yaml file exists
   if [ ! -f $YAML1 ]; then
        echo "File "$YAML1" does not exist"
fi

#4) check that the second yaml file exists
 if [ ! -f $YAML2 ]; then
                 echo "File "$YAML2" does not exist"
 fi

#5) check that the JSON repository exists

if [ ! -d $JSON ]; then
       echo "The "$JSON" directory does not exist"
fi

#6) Read the yaml file

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

eval "$(parse_yaml $YAML2 "CONF2_")"


#For each json file "_filename" found in the directory
cd "$JSON"
for _filename in $(ls *.json); do

        #search if the file name "_filename" is listed in the yaml2 file
        #get the name of the current file tree with the right jq command
        currentTreeName=$(jq -r ".tree._id" ${_filename})

        #search in the yaml2 if we find the name of the tree
        isTreeInYaml=$(compgen -A variable | grep -c ^CONF2_${currentTreeName}__)

        if [ $isTreeInYaml -gt 0 ]; then

                       #loop on CONF2_${currentTreeName}_ variables to get the node name
                       #get the node id in the current file with the right jq command

                        OLDIFS="$IFS"
                        IFS=$'\n' # bash specific

                        currentNodesNames=$(jq -r ".tree.nodes[].displayName" ${_filename})
                       
                       for node in  $currentNodesNames; do
                        
                        isNodeinYaml=$(compgen -A variable | grep -c ^CONF2_${currentTreeName}__${node}__)
                       

                       if [ $isNodeinYaml -gt 0 ]; then
                               
                               #List all the variables of the tree
                            currentTreeNodes=$(compgen -A variable | grep  ^CONF2_${currentTreeName}__${node})
                            
                               #We loop on the variables of the tree in question
                          for key in $currentTreeNodes; do

                               #Retrieves the secret value of the attribute
                               currentkey=${!key}
                               
                               #Cut the CONF2_${currentTreeName}__${node}__ part to access the attributes directly
                               keyName=$(echo $key | sed -e "s/^CONF2_${currentTreeName}__${node}__//")
                               
                               #retrieves the node id
                               id=$(jq -rc --arg nodeName $node '.tree.nodes  |to_entries[]| select(.value.displayName==$nodeName)| .key' $_filename)
                               
                               #Change the data of the JSON files with the secret values of the second yaml file 
                               jq  ".\"nodes\".\"$id\".\"$keyName\"=\"$currentkey\"" $_filename > ${_filename}.tmp && mv ${_filename}.tmp ${_filename}

          IFS="$OLDIFS"


             #call the script getSecretValue and exchange currentkey with currentValue
             currentValue=$($JSON/getSecretValue.sh "$YAML1" "$ENV" "$currentkey")
             jq  ".\"nodes\".\"$id\".\"$keyName\"=\"$currentValue\""  $_filename > ${_filename}.tmp && mv ${_filename}.tmp ${_filename}


          done
                       fi


done

        fi
        
done
