###################################
#.SYNOPSIS
#A function that runs a script on multiple databases
#
#.DESCRIPTION
#This is a version of Run-OraScriptPw that uses Find-KeePassPassword to make passwords more secure
#A function that runs a script on multiple oracle databases.
#It is using sqlplus and credentials from an input file.
#Reads the passwords from keepas using Find-KeePassPassword from keepass-management module
#The script needs to have and exit; at the end.
#
#.PARAMETER Script
#Script that needs to be run 
#
#.PARAMETER UserDbListFile
#CSV file containing user and passwords
#User,Password,ConnectAs
#
#.PARAMETER LogFile
#Name of cumulated lof file
#
#.EXAMPLE
#Run-OracleScript -Script "script.sql" -UserDbListFile "user_db.csv" -LogFile "out.log"
#
#.NOTES
#Regarding the input parameters:
#Script file needs to contain sql\plsql s=code for oracle.
#Script needs to finish with an "exit;"" command, otherwise will 
#just get stuck waiting for an exit.
#Password file needs to be a csv file in the format below:
#Database,User,Password
#If you connect as sysdba, database field should look like "dbname as sysdba" 
#Log file will default on the Logs\log.lst
################################### 
function Run-OracleScript {
	Param (
		$Script,
		$UserDbListFile,
		$LogFile = "Logs\log.lst"
	)
	
	# Script parameter cannot be null
	if (!$Script) { Write-Host "`nScript parameter cannot be null, use 'Get-Help Run-OracleScript' command.`n"; break }

	# UserDbListFile parameter cannot be null
	if (!$UserDbListFile) { Write-Host "`nUserDbListFile parameter cannot be null, use 'Get-Help Run-OracleScript' command.`n"; break }

	#Delete old log file if it exists
	if (Test-Path $LogFile) { Remove-Item -path $LogFile}

	# Start spooling to a file
	Start-Transcript $LogFile

	#Read lines from password file; Each line r
	Get-Content $UserDbListFile | Foreach-Object {

		#If the line is commented out, skip it
		if (($_.StartsWith("#"))) { return }

		#Get connection details
		$fields = $_.split(",")

		#Output details
		Write-Host ("`r`nRunning "+$Script+" on " +$fields[0]+"`r`n")

		#Build the connection details string
		$login = $fields[1]+"/"+$fields[2]+"@"+$fields[0]
		
		#Execute script in sqlplus
		$logSql = "LogSql.lst"
		$logErr = "LogErr.lst"
		Start-Process sqlplus -NoNewWindow -Wait -ArgumentList ($login, ("@"+$Script), "exit") `
			-RedirectStandardOutput $LogSQL -RedirectStandardError $logErr
		Get-Content ($logSql,$logErr) | Write-Host
	}

	Stop-Transcript
	Remove-Item -path ($logSql,$logErr)
}