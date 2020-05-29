# On importe notre CSV
Import-csv "C:\Users\Administrator\Documents\Domain-deployment-tool\P05_Admin-test.csv" | ForEach-Object {
#On met en place nos variable
$givenName = $_.Prenom
$surname = $_.Nom
$samAccName = $givenName + " " + $surname
#On supprime les comptes
Remove-ADUser -identity $samAccName
}