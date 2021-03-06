#!/bin/bash

# Run Rita script to automate the Rita process

# Variables - Start
# Version
RRRVERSION="v1.1.4"

# text color and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1;37m'
ITALICS='\033[4;37m'
OFF='\033[0m'
# current user
IAM=$(id -u)

# RITA bin location
RITA='/usr/local/bin/rita'

# REQUIRED VAR - Zeek Logs Location
ZPATH='/hunt-xs/zeek/logs'

# Get Date -1 day
TODAY=`date +%Y-%m-%d`
YESTERDAY=`date --date=yesterday +%Y-%m-%d`
PDATE=`date --date=yesterday +%Y-%m-%d`

# REQUIRED VAR - RITA HTML Location
RHTML='/home/hunter'

# Most recent Zeek log to ingest
DBNAME=`ls $ZPATH | grep $YESTERDAY`
CZDIR=$ZPATH/$DBNAME

# Init Array
ALLZEEK=(`ls $ZPATH | grep -E "^[0-9]" | grep -v $TODAY`)
ARLEN=${#ALLZEEK[@]}
# RITA DBs if exist
RDB=(`rita show-databases`)

# Variables - Stop

# Def func - Start

# Man Page "Help Menu"
manPage(){
	echo -e "${BOLD}NAME:${OFF}"
	echo -e "\tRun-RITA-Run\n"
	echo -e "${BOLD}DESCRIPTION:${OFF}"
	echo -e "\trun-rita-run - powerful cmd line script to easily use RITA tool for analyzing Zeek Logs\n"
	echo -e "${BOLD}VERSION:${OFF}"
	echo -e "\tv1.0\n"
	echo -e "${BOLD}SYNOPSIS:${OFF}"
	echo -e "\trun-rita-run [${ITALICS}OPTION${OFF}]\n"
	echo -e "${BOLD}FLAGS:${OFF}"
	echo -e "\t${BOLD}--all, -a${OFF}                  run RITA against all Zeek logs on system"
	echo -e "\t${BOLD}--delete, -d${OFF}               delete a specific RITA DB"
	echo -e "\t${BOLD}--deleteall, -da${OFF}           delete ALL RITA databases"
	echo -e "\t${BOLD}--help, -h${OFF}                 show help"
	echo -e "\t${BOLD}--import, -i${OFF}               run RITA against most recently completed Zeek log"
	echo -e "\t${BOLD}--import-rolling, -ir${OFF}      run RITA and generate a rolling db"
	echo -e "\t${BOLD}--list, -l${OFF}                 list all required variables and current DBs in RITA"
	echo -e "\t${BOLD}--manual, -m${OFF}               select a specific Zeek log to run"
	echo -e "\t${BOLD}--print, -p${OFF}                print rita data from provided db to screen in human readable format"
	echo -e "\t${BOLD}--report, -r${OFF}               create HTML report or re-create if DB has changed"
	echo -e "\t${BOLD}--rerun, -rr${OFF}               rerun RITA on provided Zeek logs"
	echo -e "\t${BOLD}--version, -v${OFF}              output version info\n"
	echo -e "${BOLD}EXAMPLES:${OFF}"
	echo -e "\tsudo run-rita-run --all\n"
	echo -e "${BOLD}AUTHOR:${OFF}"
	echo -e "\tWritten by Gabriel Simches\n"
	echo -e "${BOLD}COPYRIGHT${OFF}"
	echo -e "\tThis is free software\n"
	return $1
}

# command flag to initiate html-report
ritaHTML(){
if [ -d $RHTML/rita-html-report ]
then
	echo "RITA HTML report exists"
	# delete current report
	echo "deleting current RITA report..."
	rm -rf $RHTML/rita-html-report/*
	rmdir $RHTML/rita-html-report
	# cd into report location; create new report
	cd $RHTML
	echo "creating new RITA report..."
	rita html-report
else
	# cd into report location; create report
	cd $RHTML
	echo "creating RITA report..."
	rita html-report
fi
}

# command flag to run RITA against all Zeek Logs
ritaALL(){
for l in ${ALLZEEK[@]}
do
	rita import $ZPATH/$l $l
done
}

# rita command
ritaImport(){
if [[ `rita show-databases | grep $DBNAME` ]]
then
	echo "RITA db exists for Zeek logs for $DBNAME"
elif [[ `ls $ZPATH | grep $YESTERDAY` = $YESTERDAY ]]
then
	echo "running RITA on Zeek logs for $DBNAME"
	rita import $CZDIR $DBNAME
else
	echo "run-RITA-run ran into an unexpected issue... exiting now..."
	exit 1
fi
}

# check if required unique variables are set for local system
varCheck(){
if [ -z $1 ]
then
	echo "Required variable is not set.  Review variables, add value, and run script again."
	exit 1
fi
}

# command flag for manual log date selection
manualSelect(){
	# prompt user for date selection YYYY-MM-DD
	read -p "What Zeek log date do you want to run RITA [YYYY-MM-DD]: " MANDATE
	# check if db exists
	if [[ " ${RDB[@]} " =~ " ${MANDATE} " ]]
	then
		# if exists, let user know	
		echo "Zeek data from $MANDATE already exists in RITA"
		# ask to select another date or exit
		echo "run command again and select a different date"
	else	
		# if does not exist, run rita on manual date selection
		rita import $ZPATH/$MANDATE $MANDATE
fi
}

# command flag to rerun RITA on previously run log analysis
reRun(){
	read -p "What Zeek log are we rerunning? [YYYY-MM-DD]: " REDO
	if [[ " ${RDB[@]} " =~ " ${REDO} " ]]
	then
		echo "Deleting RITA db for $REDO..."
		sleep 1
		rita delete-database $REDO -f
		sleep 1
		rita import $ZPATH/$REDO $REDO
	else
		echo -e "${RED}RITA DB does not exist for [$REDO]${OFF}"
		echo -e "Use following command: ${YELLOW}sudo run-rita-run -m${OFF} to generate RITA DB"
		exit 1
fi
}

# command flags delete and database
dbDelete(){
	echo "Select database from list below to delete:"
	echo "LoAdiNg..."
	sleep 2
	for db in ${RDB[@]}
	do
		echo $db
	done
	# prompt user to select db for deletion
	read -p "Which database do you want to delete?: " DELETEDB
	rita delete-database $DELETEDB
}

dbDeleteAll(){
	echo "[!] Are you sure?  This is the last chance to stop this operation before deleting ALL RITA DATABASES..."
	read -p "[y/N]: " ANS
	case $ANS in
		y | Y | yes | YES | Yes)
		for db in ${RDB[@]}
		do
			rita delete-database $db -f
		done
		;;
		n | N | no | NO | No)
			echo "Good thing I asked... Aborting operations..."
		;;
		*)
			echo "Invalid Selection"
			exit 1
		;;
	esac
}

listAllRITA(){
	# list all variables and dbs
	echo "==========RITA Databases=========="
	for db in ${RDB[@]}
	do
		echo $db
	done
	echo "==========Variables=========="
	echo 'RITA=/usr/local/bin/rita'
	echo 'ZPATH=/hunt-xs/zeek/logs'
	echo -e "RHTML=/home/hunter\n\n"
}

printBeacons(){
	read -p "Enter DB name to print to screen: " SHOWME
	rita show-beacons -H $SHOWME | less
}

importRolling(){
	 rita import --rolling $ZPATH/* rollingDB
}

versionCheck(){
	rita -v
}

welcomeArt(){
	echo  ".______       __    __  .__   __.        .______       __  .___________.    ___           .______       __    __  .__   __."
	echo  "|   _  \     |  |  |  | |  \ |  |        |   _  \     |  | |           |   /   \          |   _  \     |  |  |  | |  \ |  |"
	echo  "|  |_)  |    |  |  |  | |   \|  |  ______|  |_)  |    |  | \`---|  |----\`  /  ^  \   ______|  |_)  |    |  |  |  | |   \|  |"
	echo  "|      /     |  |  |  | |  . \`  | |______|      /     |  |     |  |      /  /_\  \ |______|      /     |  |  |  | |  . \`  |"
	echo  "|  |\  \----.|  \`--'  | |  |\   |        |  |\  \----.|  |     |  |     /  _____  \       |  |\  \----.|  \`--'  | |  |\   |"
	echo  -e "| _| \`._____| \______/  |__| \__|        | _| \`._____||__|     |__|    /__/     \__\      | _| \`._____| \______/  |__| \__|\n"
	echo -e "$RRRVERSION\n\n\n"
}

# Def func - End

# Script - start

# ASCII Intro
welcomeArt

# if check for any required arguments or required user

if [ $IAM -gt 0 ]
then
	echo -e "${RED}You must use sudo to run this script.${OFF}"
	exit 1
fi

# check if RITA is installed
if [[ -z `ls -l /usr/local/bin | grep rita` ]]
then
	echo "RITA not installed on system"
	echo "Install RITA then re-run command"
	exit 1
fi

# check if Zeek log location variable is null or has value
varCheck $ZPATH

# check if RITA html location varliabe is null or has value
varCheck $RHTML

case $1 in
	-a | --all)
		ritaALL
	;;
	-i | --import)
		ritaImport
	;;
	-ir | --import-rolling)
		importRolling
	;;
	-r | --report)
		ritaHTML
	;;
	-rr | --rerun)
		reRun
	;;
	-d | --delete)
		dbDelete
	;;
	-da | -ad | --deleteall)
		dbDeleteAll
	;;
	-m | --manual)
		manualSelect
	;;
	-h | --help)
	        manPage 0 # exit sucessfully
	;;
	-l | --list)
		listAllRITA
	;;
	-p | --print)
	        listAllRITA
		printBeacons
	;;
        -v | --version)
		versionCheck
	;;
	*)
		echo -e "\nCommand flags are required for this script.  Review Man Page below:\n"
		manPage 1 # exit error
esac

# Script - stop
