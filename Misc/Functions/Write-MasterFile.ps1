<#
.Synopsis
	Find all files on current path and adds them to a file 
.DESCRIPTION
	Find all files on current path recursive and adds them to a specified file in the following format
    "prefix"+"file name relative to the path"+"suffix"  
.PARAMETER InFiles
    A string representing a file name. Accepts * as wildcard for multiple files
.PARAMETER OutFile
    A String representing the ouput file name
.EXAMPLE
	Find-OraErr
	Runs with default values: LST as log file extension and output to screen 
.EXAMPLE
	Find-OraErr -Extension log
	Runs with LOG as log file extension and output to screen 
.EXAMPLE
	Find-OraErr -Extension lst -OutputFile errAll.txt
	Runs with LST as log file extension and output to errAll.txt file 

#>
function Write-MasterFile {
    [CmdletBinding()]
    [OutputType([String[]])]
    Param (   
        $Files = "*.*",
        $Prefix = "sqlplus /nolog @",
        $Suffix = $Null,
        $OutFile = $Null,
        $Replace = @(" "," ")
    )

    # So we don't get OutFile as part of get-childitem
    if(Test-Path $OutFile) {Remove-Item $OutFile}

    # if $OutFile was not introduced as a parameter exit
    if(!$OutFile) { Write-Host "Usage: Build-MasterFile [-Files] <String> -SearchString <String>"; break }
    
    # -Recurse | Resolve-Path -Relative -> this can be used to make the search reccusive   
    (Get-ChildItem ./$Files | % {$Prefix+($_.name.Replace($Replace[0], $Replace[1]))+$Suffix}) | Out-File $OutFile
    
    Read-Host "Press enter..."
}