   <#
.DESCRIPTION
    Script for add user and homefolder, only tested on Windows Server 2019
.EXAMPLE
    ListGroupMembership.ps1
.NOTES
    Author  : Guillaume FLOCH
    Version : 1.0 20200601 InitialBuild
#>

   #Variables
   #$User > On demande de maniere interactive le nom de l'utilisateur
   #$location > dossier de sortie pour notre export
   #$directory > chemin + nom de notre fichier
    $User = Read-Host 'enter Username to list the group it belongs to'
    $location = "C:\Users\Administrator\Documents\P05_Floch_Guillaume\Projet05_Floch_AD03-"
    $directory = $location + $User + ".txt"

    try{
#on la liste des groupe dont $user est membre | on filtre par nom
    Get-ADPrincipalGroupMembership $User | Select-Object Name
#on repète l'operation en ajoutant notre export
    Get-ADPrincipalGroupMembership $User | Select-Object Name | Out-File $directory
#on notifie l'emplacement de notre export
    Write-Host "File location : $directory"
#on ajoute un exit code afin de pouvoir traiter post execution nos eventuelles erreurs 
    exit 0
    }
#on traite l'erreur $user "n'existe pas"    
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
#on retourne notre erreur
    Write-Host $_ -ErrorAction Stop    
    Write-Host "Username : $User was not found, verify and try again"
#on ajoute un exit code
    Exit 1
    }