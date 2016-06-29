#!/bin/bash

########################################################
#ABSSA - Auto Backup Script for System Administrator   #
########################################################

###################################################################################################
#By Suyash Jain - www.coolgator.in                                                                #
###################################################################################################

###################################################################################################
#The script is written to take the backup of :-                                                   #
# 1) modified files in directories since last check.                                              #
# 2) modified individual files since last check                                                   #
###################################################################################################

#####################################################################################################
# > The script relies on linxu find command and its -newer and -path switch                         #
# > The script uses a list of included directories or files as well a separate list of excluded     #
#   and pass to -path switch                                                                        #
# > the script is capable of taking directories path and individual file in include and exclude list#
# > the script uses a timestamp file to compare the included files                                  #
#####################################################################################################

#################################################
#The script accepts only one command line option#
#################################################

#if debug is true, then script displays all messages
#if test mod is true, then script does not take the actual backup, it just shows the command.

DEBUG=false
TEST_MODE=false


while getopts ":hdt" option; do
  case $option in
    h) echo "usage: $0 [-h] [-d] [-t] "; exit ;;
    d) DEBUG=true ;;
    t) TEST_MODE=true ;;
    ?) echo "error: option -$OPTARG is not implemented"; exit ;;
  esac
done


##############################
#BASE AND CONFIG FILE PATHS
##############################

#################################
#The main directory of ABSSA    #
#################################

ABSSA_BASE_PATH=/home/suyashjain/abssa

$DEBUG && echo "Base Path:      $ABSSA_BASE_PATH"

##########################################################################
# The file which will be used as input, lists all directories and files, #
# which you want to monitor for changes                                  #
##########################################################################

INCLUDE_PATH_FILE=$ABSSA_BASE_PATH/config/include_paths

$DEBUG && echo "Include File Path: $INCLUDE_PATH_FILE"

##########################################################################
# The file will be used as input, lists all directories and files,       #
# which you do not want to monitor for changes                           #
##########################################################################

EXCLUDE_PATH_FILE=$ABSSA_BASE_PATH/config/exclude_paths

$DEBUG && echo "Exclude File Path: $EXCLUDE_PATH_FILE"

#################################################################################################
#The Destination folder where the modified files will be kept.                                  #
#ABSSA create the same directory structure inside backup path.                                  #
#ABSSA create the timestamp directory as base during each run inside main backup path           #
#################################################################################################


BACKUP_PATH=$ABSSA_BASE_PATH/BACKUP

$DEBUG && echo "Backup Base Path: $BACKUP_PATH"

LATEST_BKP_FOLDER=$ABSSA_BASE_PATH/BACKUP/`date +%Y-%m-%d-%H-%M`

$DEBUG && echo "Backup Current Path: $LATEST_BKP_FOLDER"

#########################################################################
# Do not make any changes to the file once created.                     #
# If the file does not exist kindly create with touch command.          #
# KEEP THIS FILE OUT OF YOUR SEARCH AREA                                #
#########################################################################


TIMESTAMP_FILE=$ABSSA_BASE_PATH/DNT/timestamp

$DEBUG && echo "TimeStamp file: $TIMESTAMP_FILE"

#################################################################################
# Create timestamp file for first time if does not exist,                       #
# if the file is deleted frequently then the script results will be misleading. #
#################################################################################


if [ ! -f $TIMESTAMP_FILE ]; then

        $DEBUG && echo "Created $TIMESTAMP_FILE for first time only."
        touch $TIMESTAMP_FILE

fi

#########################################################
#Check if INCLUDE_PATH_FILE is available and not empty  #
#########################################################


if [ -s $INCLUDE_PATH_FILE ]; then

        $DEBUG && echo "Using $INCLUDE_PATH_FILE as source"

else

        echo "Error: config file $INCLUDE_PATH_FILE is missing or empty"

exit 1;

fi

#########################################
#Create Backup path if not exist        #
#########################################

$DEBUG && echo "Createing $BACKUP_PATH, IF DOES NOT EXIST"
mkdir -p $BACKUP_PATH || exit 1;

#########################################################################
#prepare the exclude parameteres which will be pass to find command     #
#########################################################################

EXCLUDE_LIST=''

while read FILE
do

        FILE=${FILE%/}

        if [ -d $FILE ]; then

                $DEBUG && echo "Adding Directory $FILE to exclude list"
                EXCLUDE_LIST="$EXCLUDE_LIST -not -path \"$FILE/*\""

        elif [ -f $FILE ]; then

                $DEBUG && echo "Adding File $FILE to exclude list"
                EXCLUDE_LIST="$EXCLUDE_LIST -not -path \"$FILE\""
        fi


done < $EXCLUDE_PATH_FILE

###########################################################################################
# now we will run the actual find command on included list one by one with excluded paths #
###########################################################################################

#TODO - I could not include all search folders into single command.

while read FILE

do

        for OUT in `find $FILE -type f  $EXCLUDE_LIST -newer $TIMESTAMP_FILE -print  2> /dev/null `
        do


                mkdir -p $LATEST_BKP_FOLDER

                FILE_NAME=`basename $OUT`

                $DEBUG && echo "File $OUT is updated"

                NEW_PATH=$LATEST_BKP_FOLDER`echo $OUT | sed -e "s/$FILE_NAME//"`


                        $DEBUG && echo $NEW_PATH;

                        $TEST_MODE && echo "Execute: mkdir -p $NEW_PATH"
                        $TEST_MODE && echo "Execute: cp $OUT $NEW_PATH/"

                        $TEST_MODE || mkdir -p $NEW_PATH && $DEBUG && echo "Created new path $NEW_PATH"
                        $TEST_MODE || cp $OUT $NEW_PATH/ && $DEBUG && echo "Copied file $OUT"

        done


done < $INCLUDE_PATH_FILE




##############################################################
#in the last change the modified time of our timestamp file
##############################################################

touch $TIMESTAMP_FILE


exit 0;
