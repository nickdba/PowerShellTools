# Nick (Laurentiu) Alexandrescu
# Trim the content of log files files in the current folder 
# and copy them in an output folder
# In _ErrParseOut\errors.txt you can find the summary of the errors

cls

# Reads the log files extension; the default extension is LST
# If the user introduces an extension longer than 4 chars then he gets the default 
$logExt = (Read-Host "`nWhat is the log file extension?[lst]").tolower().Trim(".")
if ((!$logExt) -or ($logExt.Length -gt 4)) { $logExt = "lst" } 

#Exit if no files with mentioned extension are found in the current folder
if (!(Test-Path ".\*.$logExt")) { Read-Host "`nNo *.$logExt files in the current folder `n`nPress Enter..."; Exit}

#Intializing variables
$errArr = @()

#Read error strings from the errors.csv file
try {
    (Get-Content .\errors.csv -ErrorAction Stop) | Foreach-Object {   
    
        #If emtpy line or commented line, skip it
	    if (($_ -match "^\s*$") -or ($_ -match "^(.s)*#.*$")) { return }
    
        $errArr += $_.split(",").trim(); 

        Write-Host $errArr

    }
} catch {
        Write-Host "Error Message: $_.Exception.Message Failed Item: $_.Exception.ItemName"; 
        Read-Host "`nNo Error file Present`n`nPress Enter..."
        Break
}

#Split file template
if (Test-Path .\splitTemplate.txt) { 
    (Get-Content .\splitTemplate.txt) | Foreach-Object {   
    
        #If emtpy line or commented line, skip it
	    if (($_ -match "^\s*$") -or ($_ -match "^(.s)*#.*$")) { return }
    
        if (!$beginSplit) { $beginSplit = $_ }
            else { $endSplit = $_ } 
    }
}

   
#Delete old outup folder if it exists
if (Test-Path .\_ErrParseOut) { Remove-Item -path .\_ErrParseOut -recurse }

# Creates trimmed folder and errors files
New-Item -path . -name _ErrParseOut -type directory
New-Item -path .\_ErrParseOut -name errors_trimmed.txt -type file
New-Item -path .\_ErrParseOut -name errors_full.txt -type file

# Gets all the log files and for each of them ...
$files = Get-ChildItem .\*.LST
foreach ($file in $files){
	# Creates a new log file in trimmed folder
	New-Item -path .\trimmed -name $file.name -type file
	
	# contentFlag used for monitor the content of the log file
	$contentFlag = 0;
	
	# Gets all the lines of the log file and for each of them ... 
	$lines = Get-Content $file.FullName
	foreach ($line in $lines) {
		$lineLowerCase = $line.ToLower()
		
		# Check for the actual beginning of the log and set the content contentFlag
		If($lineLowerCase.Contains("start of deployment scripts")) { $contentFlag = 1 }

		# Copy only the log content in the new file
		If($contentFlag -eq 1) {
			if ($file.name.length -gt 12 -and $trimLogName -eq "y" ) {
				$fileName = ($file.name.Substring(0,12)+".LST")
			}
			else {
				$fileName = $file.name
			}
			Add-Content -path (".\trimmed\" + $fileName) -value $line
		}
		
		# Check for errors and insert into errors files
		If(($lineLowerCase.Contains("ora-") -or $lineLowerCase.Contains("pls-") -or $lineLowerCase.Contains("sp2-")`
		-or $lineLowerCase.Contains("unable") -or $lineLowerCase.Contains("warning") -or $lineLowerCase.Contains("dropped")`
		-or $lineLowerCase.Contains("0 rows updated") -or $lineLowerCase.Contains("dbs-"))) {

			Add-Content -path .\trimmed\errors_full.txt -value ($file.name+": "+$line)
			If($contentFlag -eq 1) {
				Add-Content -path .\trimmed\errors_trimmed.txt -value ($file.name+": "+$line)
			}
		}
		
		# Check for the actual beginning of the log and set the content contentFlag
		If($lineLowerCase.Contains("end of deployment scripts")) { $contentFlag = 0 }
	}
	
	# Delete empty files
	If((Get-Content -path (".\trimmed\" + $file.name)) -eq $Null){
		Remove-Item -path (".\trimmed\" + $file.name)
	}
}