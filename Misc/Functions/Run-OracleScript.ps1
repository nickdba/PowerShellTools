###################################
#.SYNOPSIS
#A function that runs a script on multiple databases
#
#.DESCRIPTION
#This function is a version of Run-OraScriptPw that uses Find-KeePassPassword to make passwords more secure
#The purpose is to run a script on multiple oracle databases.
#It is using sqlplus to connect to the database and credentials from an input file.
#Reads the passwords from keepas using Find-KeePassPassword from keepass-management module
##
#.PARAMETER Script
#Script that needs to be run
#
#.PARAMETER ConnDetailsFile
#CSV file containing connection details
#User,Database,ConnectAs
#
#.PARAMETER LogFile
#Name of cumulated log file
#
#.EXAMPLE
#Run-OracleScript -Script "script.sql" -ConnDetailsFile "conn_details.csv" -LogFile "out.log"
#
#.NOTES
#Regarding the input parameters:
#Script file needs to contain sql\plsql code for oracle.
#Script needs to finish with an "exit;"" command, otherwise will 
#just stuck waiting for an exit.
#Connection Details File needs to be a csv file in the format below:
#User,Database,ConnectAs
#If you connect as sysdba, ConnectAs field should say "as sysdba", otherwise can be ignored 
#Log file will default on the Logs\log.lst
################################### 
function Run-OracleScript {
	Param (
		$Script,
		$ConnDetailsFile,
		$LogFile = "Logs\log.lst"
	)
	
	# Script parameter cannot be null
	if (!$Script) { Write-Host "`nScript parameter cannot be null, use 'Get-Help Run-OracleScript' command.`n"; break }

	# ConnDetailsFile parameter cannot be null
	if (!$ConnDetailsFile) { Write-Host "`nConnDetailsFile parameter cannot be null, use 'Get-Help Run-OracleScript' command.`n"; break }

	#Delete old log file if it exists
	if (Test-Path $LogFile) { Remove-Item -path $LogFile}

	# Start spooling everything to the log file
	Start-Transcript $LogFile

	#Read lines from connection details file; Each line represents a database connection
	Get-Content $ConnDetailsFile | Foreach-Object {

		#If the line is commented out, skip it
		if (($_.StartsWith("#"))) { return }

		#Get connection details
		$fields = $_.split(",")

		#Output details
		Write-Host ("`r`nRunning "+$Script+" on " +$fields[1]+"`r`n")

		
		#Build the connection details string
		$login = $fields[0]+"/"+$fields[2]+"@"+$fields[1]
		
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