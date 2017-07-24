###################################
#.SYNOPSIS
#A function that runs a script on multiple databases
#
#.DESCRIPTION
#A function that runs a script on multiple oracle databases.
#It is using sqlplus and an input password file for credentials. 
#The script needs to have and exit; at the end.
#
#.PARAMETER Script
#Script that needs to be run 
#
#.PARAMETER PassFile
#CSV file containing user and passwords
#Database,User,Password
#
#.PARAMETER LogFile
#Name of cumulated lof file
#
#.EXAMPLE
#Run-DailyChecksPw -Script "test_script.sql" -PassFile "pass_dev.csv"
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
function Run-DailyChecksPw {
	Param (
		$Script,
		$PassFile = "pass_dev.csv",
		$LogFile = "Logs\log.lst"
	)
	
	# Script parameter cannot be null
	if (!$Script) { Write-Host "`nScript parameter cannot be null, use 'Get-Help Run-DailyChecksPw' command.`n"; break }

	# PassFile parameter cannot be null
	if (!$PassFile) { Write-Host "`nPassFile parameter cannot be null, use 'Get-Help Run-DailyChecksPw' command.`n"; break }

	#Delete old log file if it exists
	if (Test-Path $LogFile) { Remove-Item -path $LogFile}

	# Start spooling to a file
	Start-Transcript $LogFile

	#Read lines from password file; Each line r
	Get-Content $PassFile | Foreach-Object {

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