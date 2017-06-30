get-childitem $psscriptroot\Functions\*.ps1 -recurse | %{ . $_.Fullname }

Set-Alias fo Find-OraErr
Set-Alias fs Find-String
Set-Alias wm Write-MasterFile