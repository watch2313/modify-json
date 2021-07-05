#!/bin/bash

PATH_FOLDER="/path/to"
AUTOMATIZATION_SCRIPT="${PATH_FOLDER}/script/automatization.sh"
UPDATE_SCRIPT="${PATH_FOLDER}/script/update.sh"
PATH_GETSECRETVALUE="${PATH_FOLDER}/script/getSecretValue.sh"
PATH_JENKINS="${PATH_FOLDER}/.jenkins/workspace/import/amtrees"
GETSECRETVALUE_SCRIPT="${PATH_JENKINS}/getSecretValue.sh"
PATH_AUTOMATIZATION="${PATH_JENKINS}/automatization.sh"
PATH_UPDATE="${PATH_JENKINS}/updatejson.sh"
EXECUTE_AUTOMATIZATION="${PATH_AUTOMATIZATION} $ENV $FUNCTION"
EXECUTE_UPDATE="${PATH_UPDATE} $MODE $JSON $YAML2 $YAML1 $ENV"
GIT_CLONE="git@gitlab.com:user/repository.git"

#Check the automation repository clone 
if [ -d $PATH_JENKINS ]; then
    echo "The directory already exists"
else
    git clone "$GIT_CLONE"
fi

#Copy the automation script 
if [ -f "$PATH_AUTOMATIZATION" ]; then
   echo "The copy of automatization.sh has already been done"
else
   cp "$AUTOMATIZATION_SCRIPT" "$PATH_JENKINS"
fi

#Copy the update script
if [ -f $PATH_UPDATE ]; then
   echo "The copy of update.sh has already been done"
else
   cp "$UPDATE_SCRIPT" "$PATH_JENKINS"
fi

#Copy getSecretValue file
if [ -f "$GETSECRETVALUE_SCRIPT" ]; then
      echo "The getSecretValue script has already been done"
else
      cp "$PATH_GETSECRETVALUE" "$PATH_JENKINS"
fi

#Import the trees that are in gitlab in the directory
git pull origin

#Add the data in the JSON files
"$EXECUTE_UPDATE"

#Import the trees in AM
"$EXECUTE_AUTOMATIZATION"

