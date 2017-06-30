<#
.Synopsis
	Find all the files that contain a given string
.DESCRIPTION
	Find all the files that contain a given string
	The search is done reccursive
	-Files <file_name> can use * as wildcard
.EXAMPLE
	Find-String -SearchString break
	Will search string "break" on all files including subdirectories 
.EXAMPLE
	Find-String -SearchString "break|write"
	Will search string "break" or "write" or on all files including subdirectories
.EXAMPLE
	Find-String -Files *.ps1 -SearchString child
	Will search string "child" on all files with ps1 as extension including subdirectories
#>
function Find-String {
	Param (
		# Extension of files searched, default is *.*, multiple extensions allowed *.lst
        $Files = "*.*",
        # String searched, default is null and will promt the usage
        $SearchString = $Null
	)

	# Search String cannot be null
	if (!$SearchString) { Write-Host "Usage: Find-String [-Files] <String> -SearchString <String>"; break }
	
	# Get all the files and search the string in them 
	Get-ChildItem -recurse -Path $Files | Select-String -pattern $SearchString
	Read-Host "Press Enter..."
}
