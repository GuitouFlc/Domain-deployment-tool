    $User = Read-Host 'enter Username to list the group it belongs to'
    $location = "C:\Users\Administrator\Documents\P05_Floch_Guillaume\Projet05_Floch_AD03-"
    $directory = $location + $User + ".txt"
    try{
    Get-ADPrincipalGroupMembership $User | Select-Object Name | Out-File $directory
    Write-Host "File location : $directory"
    exit 0
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    Write-Host $_ -ErrorAction Stop
    Write-Host "Username : $User was not found, verify and try again"
    Exit 1
    }