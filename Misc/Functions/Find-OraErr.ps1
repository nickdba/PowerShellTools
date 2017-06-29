<#
.Synopsis
   Find the Oracle Errors in multimple log files
.DESCRIPTION
   Find the Oracle Errors in multimple log files
.EXAMPLE
   Find-OraErr
   Find-OraErr -Extension lst
   Find-OraErr -Extension lst -OutputFile errAll.txt
#>
function Find-OraErr {
    [CmdletBinding()]
    [OutputType([String[]])]
    Param
    (   # Extension of log files
        $Extension = "LST",
        # Entry to find in DB
        $OutputFile = $Null
    )

    if ($OutputFile) { Select-String -Path "*.$Extension" -pattern "ora-|pls-|sp2-|dbs-|unable|warning|dropped|0 rows updated"| out-file $OutputFile }
        else { Select-String -Path "*.$Extension" -pattern "ora-|pls-|sp2-|dbs-|unable|warning|dropped|0 rows updated" }

}