#!/bin/bash

#1) retrieving command line arguments in variables
MODE=$1
JSON=$2
YAML2=$3
YAML1=$4
ENV=$5

#We need the parse_yaml.sh script wich contains the function that parses the yaml files
source /path/to/parse_yaml.sh

#2) Determine to run the script as delete or update
if [ $# -le 3 ]; then
     echo "This script is for deleting data in the JSON files"
elif [ $# -le 5 ]; then 
     echo "This script is for adding data in the JSON files"
else
     exit
fi

#3) check that the first yaml file exists
if [ ! -f "$YAML1" ]; then
   echo "File $YAML1 does not exist"
fi

#4) check that the second yaml file exists
 if [ ! -f "$YAML2" ]; then
    echo "File $YAML2 does not exist"
 fi

#5) check that the JSON repository exists

if [ ! -d "$JSON" ]; then
   echo "The $JSON directory does not exist"
fi

#6) Read the yaml file, the function is in the parse_yaml.sh script
eval "$(parse_yaml $YAML2 "CONF2_")"


#For each json file "_filename" found in the directory
cd "$JSON"
for _filename in $(ls *.json); do

    #search if the file name "_filename" is listed in the yaml2 file
    #get the name of the current file tree with the right jq command
    currentTreeName=$(jq -r ".tree._id" ${_filename})

    #search in the yaml2 if we find the name of the tree
    isTreeInYaml=$(compgen -A variable | grep -c ^CONF2_${currentTreeName}_)

    if [ $isTreeInYaml -gt 0 ]; then

       #loop on CONF2_${currentTreeName}_ variables to get the node name
       #get the node id in the current file with the right jq command

       OLDIFS="$IFS"
       IFS=$'\n' # bash specific

       currentNodesNames=$(jq -r ".tree.nodes[].displayName" ${_filename})
                       
       for node in  $currentNodesNames; do
                        
           isNodeinYaml=$(compgen -A variable | grep -c ^CONF2_${currentTreeName}_${node}_)
                               
           if [ $isNodeinYaml -gt 0 ]; then
                               
              #List all the variables of the tree
              currentTreeNodes=$(compgen -A variable | grep  ^CONF2_${currentTreeName}_${node}_)
                            
              #We loop on the variables of the tree in question
              for key in $currentTreeNodes; do

                  #Retrieves the secret value of the attribute
                  currentkey=${!key}
                               
                  #Cut the CONF2_${currentTreeName}_${node}_ part to access the attributes directly
                  keyName=$(echo $key | sed -e "s/^CONF2_${currentTreeName}_${node}_//")
                               
                  #retrieves the node id
                  id=$(jq -rc --arg nodeName $node '.tree.nodes  |to_entries[]| select(.value.displayName==$nodeName)| .key' $_filename)
                             
                  #Choose between deleting the data and adding it
                  if [ "$MODE" == "delete" ]; then
                               
                      #Delete the data of the JSON file
                      jq  ".\"nodes\".\"$id\".\"$keyName\"=\"null\"" $_filename > ${_filename}.tmp && mv ${_filename}.tmp ${_filename}

                   elif [ "$MODE" == "add" ]; then
                        #Add the data
                        #Change the data of the JSON files with the secret values of the second yaml file 
                        jq  ".\"nodes\".\"$id\".\"$keyName\"=\"$currentkey\"" $_filename > ${_filename}.tmp && mv ${_filename}.tmp ${_filename}
                                             
                        #call the script getSecretValue and exchange currentkey with currentValue
                        currentValue=$($JSON/getSecretValue.sh "$YAML1" "$ENV" "$currentkey")
                        
                        #Remove double quotes from the value of minimumPasswordLength because it is an integer 
                        if [ "$keyName" == "minimumPasswordLength" ]; then
                             jq  ".\"nodes\".\"$id\".\"$keyName\"=$currentValue"  $_filename > ${_filename}.tmp && mv ${_filename}.tmp ${_filename}
                        else
                             jq  ".\"nodes\".\"$id\".\"$keyName\"=\"$currentValue\""  $_filename > ${_filename}.tmp && mv ${_filename}.tmp ${_filename}
                        fi
          
                    fi
                    
             done
             
        fi

    done
    
 fi
       
done
