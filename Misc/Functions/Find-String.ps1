##############################
#.SYNOPSIS
#Find all the files that contain a given string
#
#.DESCRIPTION
#Find all the files that contain a given string
#The search is done reccursive
#-Files <file_name> can use * as wildcard
#
#.PARAMETER Files
#Extension of files searched, default is *.*, multiple extensions allowed *.lst
#
#.PARAMETER SearchString
#String searched, default is null and will prompt the usage
#
#.EXAMPLE
#Find-String -SearchString break
#Will search string "break" on all files including subdirectories 
#
#.EXAMPLE
#Find-String -SearchString "break|write"
#Will search string "break" or "write" or on all files including subdirectories
#
#.EXAMPLE
#Find-String -Files *.ps1 -SearchString child
#Will search string "child" on all files with ps1 as extension including subdirectories
#
#.NOTES
#General notes
##############################
function Find-String {
	Param (
		[ValidatePattern("\w+")] 
		[String] $Files = "*.*",
		
		[Parameter(Mandatory=$true)]
		[String] $SearchString
	)
	
	# Get all the files and search the string in them 
	Get-ChildItem -Recurse -Path $Files | Select-String -pattern $SearchString
	Read-Host "Press Enter..."
}
