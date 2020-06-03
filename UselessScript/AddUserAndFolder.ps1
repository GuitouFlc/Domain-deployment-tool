<#
.DESCRIPTION
    Script for add user and homefolder, only tested on Windows Server 2019
.EXAMPLE
    AddUserAndFolder.ps1
.NOTES
    Author  : Guillaume FLOCH
    Version : 1.0 20200601 InitialBuild
#>

## Execute as Administrators
#On déclare nos variables
$firstname = Read-Host "Enter firstname"
$surname = Read-Host "Enter name"
$samAccName = $firstname + " " + $surname
$DefaultPassword = (ConvertTo-SecureString "Password2019" -AsPlainText -Force)

#On crée notre User
try {
New-ADUser -name $samAccName -GivenName $firstname -surname $surname `
            -AccountPassword $DefaultPassword `
            -SamAccountName $samAccName
            Write-Host $samAccName "is been create"
#On force le renouvellement de mot de passe à la premiere authentification            
            set-ADUser -identity $samAccName -ChangePasswordAtLogon $true
            Write-Host "Password must be changed at first log"
}
#Si notre user existe déja on quitte
catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException]{
        Write-Host $_
        exit 1
    }

#On active le compte dans l'AD
finally{
    Set-ADUser $samAccName -enabled $true
}

#variables  Dossier
$HomeLocation = "C:\Share\" + $samAccName
$HomeFolder = "\\" + $env:Computername + "\SHARE\" + $SamAccName
$drive = "H:"

#On parametre notre dossier / Lecteur
#On verifie si le dossier existe
if(Test-Path -path $HomeLocation){
    Write-Host $HomeLocation" exist"
}
#ou bien on le crée
else{
    New-Item -ItemType directory -Path "C:\SHARE" -Name $samAccName -ErrorAction Stop
} 
#On parametre le dossier pour notre user et on en profite pour le monter en H:
    Set-ADUser -Identity $samAccName -HomeDirectory $HomeFolder -HomeDrive $Drive
    Write-Host "Home folder for " $samAccName" is now available on " $Drive
    Write-Host "Network Location : " $HomeFolder
    Write-Host "Care at this point user have no rights for use his directory"
Exit 0