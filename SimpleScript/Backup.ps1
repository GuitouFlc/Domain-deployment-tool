
## Variables (script test > seul le dossier P05_Floch_Guillaume est sauvegardé dans l'exemple ci-dessous)

$source = "C:\Users\" + $env:USERNAME + "\Documents\P05_Floch_Guillaume" 
$destination = "\\WIN-TBJAIATCNLN\SAV\" + $env:COMPUTERNAME
$logfile = "C:\SAV\logfile" + $env:COMPUTERNAME + ".txt"

#On test si notre dossier n'existe pas > on le crée
if (!(Test-Path -Path $destination)){
    New-Item $destination -type directory
}

# /XO ne pas copier les données déja présentent
# /COPYALL copie l'ensemble des infos (idem : copy:DATSOU)
# /E /Purge inclus les sous repertoires >> purge les dossiers inexistant
# /R nombre d'essais en cas d'echec
# /log respertoire pour les logs
# /NP on n'affiche pas la progression
robocopy $source $destination *.* /XO /COPYALL /E /Purge /R:5 /log:$logfile /NP
