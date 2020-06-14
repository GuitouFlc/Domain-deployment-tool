<#
.DESCRIPTION
    Script for add user and homefolder, only tested on Windows Server 2019
.EXAMPLE
    AddUserAndFolder.ps1
.NOTES
    Author  : Guillaume FLOCH
    Version : 1.0 20200601 InitialBuild
#>

#variables
#$GroupIn > on recupere de manière interractive le nom d'un groupe
#$location > dossier de sortie pour notre export
#$directory > chemin + nom de notre fichier
$GroupIn = Read-Host "Enter Group Name"
$location = "C:\Users\Administrator\Documents\P05_Floch_Guillaume\Projet05_Floch_AD02-"
$directory = $location + $GroupIn + ".txt"

try {
    #on recupère la liste des membre de $GroupIn | on filtre par nom
    Get-ADGroupMember -Identity "$GroupIn" | Select-Object -property Name
    #on ajout notre option d'export 
    Get-ADGroupMember -Identity "$GroupIn" | Select-Object -property Name | Out-File $directory -ErrorAction Stop
    #on ajoute un exit code pour traiter d'eventuelle erreur post-execution
    exit 0
}
#on traite l'erreur $GroupIn "n'existe pas"
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    #on retourne l'erreur
    Write-Host $_
    #on ajoute un exit code
    exit 1
}

