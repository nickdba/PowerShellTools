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
$errRegex = @()
$outputDir = ".\_ErrParseOut"

#Read error strings from the errors.csv file
try {
    (Get-Content .\errors.csv -ErrorAction Stop) | Foreach-Object {   
    
        #If emtpy line or commented line, skip it
	    if (($_ -match "^\s*$") -or ($_ -match "^(.s)*#.*$")) { return }
    
        $errRegex += $_.split(",").trim() 

        Write-Host $errRegex

    }
} catch {
        Write-Host "Error Message: $_.Exception.Message Failed Item: $_.Exception.ItemName"; 
        Read-Host "`nNo Error file Present`n`nPress Enter..."
        Break
}

$errRegex = $errRegex -join "|"

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
if (Test-Path $outputDir) { Remove-Item -path $outputDir -recurse }

# Creates trimmed folder and errors files
New-Item -path . -name $outputDir.Substring(2) -type directory
New-Item -path $outputDir -name errAll.txt -type file
New-Item -path $outputDir -name errSplitFile.txt -type file

# Gets all the log files and for each of them ...
$files = Get-ChildItem ".\*.$logExt"
foreach ($file in $files){
	
    # Reset splitfile content flag
    $contentFlag = $FALSE;

	# If beginSplit variable is present this means a trimmed file will be created
    if($beginSplit) { New-Item -path $outputDir -name $file.name -type file;}
            	
	# Gets all the lines of the log file and for each of them ... 
	Get-Content $file.FullName -ReadCount 100| Foreach-Object {
        
        if  ($_ -match "$beginSplit|$endSplit|$errRegex") {
                
            foreach ($line in $_) {
		
		        # Check for beginning of splitlog file and set the contentFlag
		        if($beginSplit -and ($line -match $beginSplit)) { $contentFlag = $TRUE }

		        # Copy only the log content in the new file
		        if($contentFlag) { Add-Content -path ("$outputDir\" + $file.name) -value $line }
		
		        # Check for errors and insert into errors files
                if($line -match $errRegex) {
                    Add-Content -path "$outputDir\errAll.txt" -value ($file.name+": $line")
		            if($contentFlag) { Add-Content -path "$outputDir\errSplitFile.txt" -value ($file.name+": $line") }
                }
        
		        # Check for ending of splitlog file and unset the contentFlag
		        if($endSplit -and ($line -match $endSplit)) { $contentFlag = $FALSE }
            }
        }
        elseif($contentFlag) { Add-Content -path ("$outputDir\" + $file.name) -value $_ } 
	}
	
	# Delete empty files
	if((Get-Content -path ("$outputDir\" + $file.name)) -eq $Null){
		Remove-Item -path ("$outputDir\" + $file.name)
	}
}