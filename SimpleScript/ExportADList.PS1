$Directory = "C:\Users\Administrateur\Documents\P5_Floch_Guillaume\"
$FileUsers = "ExportUser"
$FileGroups = "ExportGroup"
$FileShare = "ExportShare"
$CompletUser = $directory + $FileUsers + ".txt"
$CompletGroup = $directory + $FileGroups + ".txt"
$CompletShare = $Directory + $FileShare + ".txt"


Get-ADUser -filter * -properties Name | Select-Object Name | Out-File $CompletUser
Write-Host "User list exported"
Get-ADGroup -filter * -properties Name | Select-Object Name |Out-File $CompletGroup
Write-Host "Group list exported"
Get-SmbShare | Out-File $CompletShare
Write-Host "Share list exported"