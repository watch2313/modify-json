#!/bin/bash

PATH_FOLDER="/path/to"
PATH_JENKINS="${PATH_FOLDER}/.jenkins/workspace/export/amtrees"
AUTOMATIZATION_SCRIPT="${PATH_FOLDER}/script/automatization.sh"
UPDATE_SCRIPT="${PATH_FOLDER}/script/updatejson.sh"
PATH_AUTOMATIZATION="${PATH_JENKINS}/automatization.sh"
PATH_UPDATE="${PATH_JENKINS}/updatejson.sh"
EXECUTE_AUTOMATIZATION=${PATH_AUTOMATIZATION} "$ENV" "$FUNCTION"
EXECUTE_UPDATE=${PATH_UPDATE} "$MODE" "$JSON" "$YAML2"
GIT_CLONE="git@gitlab.com:user/repository.git"

source "$EXECUTE_AUTOMATIZATION"
source "$EXECUTE_UPDATE"

#Check the automation repository clone 
if [ -d $PATH_JENKINS ]; then
    echo "The repository already exists"
else
    git clone "$GIT_CLONE"
fi

#Copy the automation script 
if [ -f "$PATH_AUTOMATIZATION" ]; then
   echo "The copy of automatization.sh has already been made "
else
   cp "$AUTOMATIZATION_SCRIPT" "$PATH_JENKINS"
fi

#Copy the update script
if [ -f $PATH_UPDATE ]; then
   echo "The copy of update.sh has already been made "
else
   cp "$UPDATE_SCRIPT" "$PATH_JENKINS"
fi


#Export all am trees in this directory
cd "$PATH_JENKINS"
"$EXECUTE_AUTOMATIZATION"

#Remove sensitive data from json files 
"$EXECUTE_UPDATE"

#Push to git
git pull origin main
git add *
git commit -m "AM_TREES"
git push -u origin main
