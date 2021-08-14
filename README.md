# Run-RITA-Run | Version 1.0
> Open-source tool making RITA easier to use

This tools is designed to work with the RITA (Real Intelligence Threat Analytics) tool avaiable at: https://github.com/activecm/rita
***RITA must be installed on the system for this tool to work***

Get started by following the installation steps below:

**How-To Install**
```
git clone https://github.com/jeffvader84/run-rita-run/
cd run-rita-run
sudo chmod +x run-rita-run.sh
sudo cp run-rita-run.sh /usr/local/bin/run-rita-run
cd ..
rm -rf run-rita-run/*
rmdir run-rita-run
```

**How-To Configure**

Every system can be different.  In order to make sure run-rita-run works properly, you need to **uncomment** and **edit** the *REQUIRED* variables in the tool in order for it to find your Zeek logs and add the location you want the HTML file to be saved at.  The best place for the HTML location is wherever you plan to have the webservice point to.  For example, the default Apache directory if you plan to use Apache.

***Please Note!***
The tool will not run if you leave these variables alone.

## How-To Use
Using the tool is simple and easy!  Just run the command as root or sudo with the optional flag of what you want it to do.  Here is a copy of the help menu:
```
.______       __    __  .__   __.        .______       __  .___________.    ___           .______       __    __  .__   __.
|   _  \     |  |  |  | |  \ |  |        |   _  \     |  | |           |   /   \          |   _  \     |  |  |  | |  \ |  |
|  |_)  |    |  |  |  | |   \|  |  ______|  |_)  |    |  | `---|  |----`  /  ^  \   ______|  |_)  |    |  |  |  | |   \|  |
|      /     |  |  |  | |  . `  | |______|      /     |  |     |  |      /  /_\  \ |______|      /     |  |  |  | |  . `  |
|  |\  \----.|  `--'  | |  |\   |        |  |\  \----.|  |     |  |     /  _____  \       |  |\  \----.|  `--'  | |  |\   |
| _| `._____| \______/  |__| \__|        | _| `._____||__|     |__|    /__/     \__\      | _| `._____| \______/  |__| \__|

v1.1.3



NAME:
	Run-RITA-Run

DESCRIPTION:
	run-rita-run - powerful cmd line script to easily use RITA tool for analyzing Zeek Logs

VERSION:
	v1.0

SYNOPSIS:
	run-rita-run [OPTION]

FLAGS:
	--all, -a                  run RITA against all Zeek logs on system
	--delete, -d               delete a specific RITA DB
	--deleteall, -da           delete ALL RITA databases
	--help, -h                 show help
	--import, -i               run RITA against most recently completed Zeek log
	--import-rolling, -ir      run RITA and generate a rolling db
	--list, -l                 list all required variables and current DBs in RITA
	--manual, -m               select a specific Zeek log to run
	--print, -p                print rita data from provided db to screen in human readable format
	--report, -r               create HTML report or re-create if DB has changed
	--rerun, -rr               rerun RITA on provided Zeek logs
	--version, -v              output version info

EXAMPLES:
	sudo run-rita-run --all

AUTHOR:
	Written by Gabriel Simches

COPYRIGHT
	This is free software
```
