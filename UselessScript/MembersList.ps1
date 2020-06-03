$GroupIn = Read-Host "Enter Group Name"
$location = "C:\Users\Administrator\Documents\P05_Floch_Guillaume\Projet05_Floch_AD02-"
$directory = $location + $GroupIn + ".txt"

try {
    Get-ADGroupMember -Identity "$GroupIn" | Select-Object -property Name | Out-File $directory -ErrorAction Stop
    exit 0
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    Write-Host $_
    exit 1
}

