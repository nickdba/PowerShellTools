get-childitem $psscriptroot\Functions\*.ps1 -recurse | %{ . $_.Fullname }
