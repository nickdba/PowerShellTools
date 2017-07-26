###################################
#.SYNOPSIS
#A function that runs a script on multiple databases
#
#.DESCRIPTION
#This function is a version of Push-OraScriptPw that uses Find-KeePassPassword to make passwords more secure
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
#Push-OracleScript -Script "script.sql" -ConnDetailsFile "conn_details.csv" -LogFile "out.log"
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
function Push-OracleScript {
	Param (
		$Script,
		$ConnDetailsFile,
		$LogFile = "Logs\log.lst"
	)
	
	# Script parameter cannot be null
	if (!$Script) { Write-Host "`nScript parameter cannot be null, use 'Get-Help Push-OracleScript' command.`n"; break }

	# ConnDetailsFile parameter cannot be null
	if (!$ConnDetailsFile) { Write-Host "`nConnDetailsFile parameter cannot be null, use 'Get-Help Push-OracleScript' command.`n"; break }

	# Delete old log file if it exists
	if (Test-Path $LogFile) { Remove-Item -path $LogFile}

	# Start spooling everything to the log file
	Start-Transcript $LogFile

	# Getting the Keepas key 
	$kEnvironment = Get-KeePassEnvironment
	
	# Logs for SqlPlus
	$logSql = "LogSql.lst"
	$logErr = "LogErr.lst"
    
	# Read lines from connection details file; Each line represents a database connection
	Get-Content $ConnDetailsFile | Foreach-Object {

		# If the line is commented out or empty, skip it
		if (($_.StartsWith("#"))) { return }
		if (($_ -match '^\s*#+') -or (!$_.trim())) {return}

		# Get connection details User,Database,ConnectAs
		$fields = $_.split(",") | ForEach-Object {$_.trim()}

		# Output details
		Write-Host ("`r`nRunning "+$Script+" on " +$fields[1]+"`r`n")

		# Get password from keepass database
		$password = (Find-KeePassPassword -KeepassEnvironment $kEnvironment -Username $fields[0] -Title $fields[1]).password

		# Connect as sysdba
		if($fields[2] -eq "as sysdba") { $database = $fields[1]+" "+$fields[2] }
		else { $database = $fields[1] }

		# Build the connection details string
		$login = $fields[0]+"/"+$password+"@"+$database
		
		# Execute script in sqlplus
		Start-Process sqlplus -NoNewWindow -Wait -ArgumentList ($login, ("@"+$Script), "exit") `
			-RedirectStandardOutput $LogSQL -RedirectStandardError $logErr
		
		# Write logs for SqlPlus to output
		Get-Content ($logSql,$logErr) | Write-Host
	}

	# Remove logs for SqlPlus	
	Remove-Item -path ($logSql,$logErr)

	# End spooling everything to the log file
	Stop-Transcript
}