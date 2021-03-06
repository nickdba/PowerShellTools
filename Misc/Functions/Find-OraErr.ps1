<#
.Synopsis
	Find Oracle errors in multiple log files
.DESCRIPTION
	Find any of the following Oracle errors in multiple log files
    ora-|pls-|sp2-|dbs-|unable|warning|dropped|0 rows updated
.PARAMETER Extension
    Extension of log files
    Default is LST
.PARAMETER  OutputFile
    Output file
    Default will output on screen
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
function Find-OraErr {
    [CmdletBinding()]
    [OutputType([String[]])]
    Param (   
        [String]$Extension = "LST",
        [String]$OutputFile = $Null
    )

    # Not found a better alternative to switch between output screen or output file
    if ($OutputFile) { Select-String -Path "*.$Extension" -pattern "ora-|pls-|sp2-|dbs-|unable|warning|dropped|0 rows updated"| out-file $OutputFile }
        else { Select-String -Path "*.$Extension" -pattern "ora-|pls-|sp2-|dbs-|unable|warning|dropped|0 rows updated"; Read-Host "Press Enter..." }

}