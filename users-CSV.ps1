<# Attention lors de la jonction d'un poste au domain il faudra utilisez le compte "Administrateur"
Le montage des dossier utilisateurs dans le cas présent sont fait à partir du serveur de fichier
comme l'ensemble des manipulations
#>
function CreateUser() {
# On appel notre fichier de conf 
    $config = $args[0]

$config.ImportCSV | ForEach-Object {
$firstname = $_.Prenom
$surname = $_.Nom
$samAccName = $firstname + " " + $surname

$config.completePath = $config.ServerDrive + "\" +$config.ShareDir
$config.HomeLocation = $config.ServerDrive + "\" + $config.Path + "\" + $SamAccName
$config.HomeFolder = "\\" + $env:Computername + "\" + $config.Path + "\" + $SamAccName

        try{
#On vient créer notre utilisateur en forçant le renouvellement du mot de passe lors de l'identification
            New-ADUser -name $samAccName -GivenName $firstname -surname $surname `
            -AccountPassword $config.DefaultPassword -ChangePasswordAtLogon $true `
            -SamAccountName $samAccName -city $_.site `
            -Title $_.Fonction -Department $_.Departement -MobilePhone $_.Mobile -OfficePhone $_.Tel2 `
            -EmailAddress $_.email -Office $_.Site
            
            Write-Host $samAccName "is been create"
        }
# si le compte existe deja on le notifie
        catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException]{
            Write-Host $_
        }
#On active ou pas l'utilisateur en fonction de son statut dans le fichier CSV        
        finally {
            if ($_.Actif -eq "OUI"){
                Set-ADUser $samAccName -enabled $true
            }
            else {
                set-ADUser $samAccName -enabled $false
                Write-Host $samAccName " isnt enabled cause : " $_.Note
            }  
        }
               
## Add home folder on 'H:'
    $Users = Get-ADUser -Filter *
    $Users | ForEach-Object {
            if($_.SamAccountName -eq $Users){
                Set-ADUser -Identity $_.SamAccountName -HomeDirectory $config.HomeFolder -HomeDrive $config.Drive
                Write-Host $_.SamAccountName" Name match with Current User"
                Write-Host "Home folder for " $_.SamAccountName" is now available on " $config.Drive
                Write-Host "Network Location : " $config.HomeFolder
            }  
        } 
        Write-Host $_.Exception   

#On configure nos variable pour la suite (gestion des droit / ACL)
#            $config.Fullcontrol= [System.Security.AccessControl.FileSystemRights]"FullControl"
            $config.Modify = [System.Security.AccessControl.FileSystemRights]"modify"
            $config.ReadAndExecute = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute"
            $config.InheritanceFlags = [System.Security.AccessControl.InheritanceFlags] 1,2
            $config.PropagationFlags = [System.Security.AccessControl.PropagationFlags] 0
            $config.AccessControl = [System.Security.AccessControl.AccessControlType]"Allow"
            
#On Verifie que le dossier existe si ce n'est pas le cas on vient le créer
            if(Test-Path -path $config.HomeLocation){
                Write-Host $config.HomeLocation" exist"
            }
            else{
                New-Item -ItemType directory -Path $config.completePath -Name $samAccName -ErrorAction Stop
            } 
## On définit de nouveaux droits pour notre utilisateur sur le dossier de partage et sur son dossier   
    $config.Account = $config.Domain + "\" + $samAccName  
                
    $acl = Get-Acl -Path $config.completePath
# On applique les droit sur le repertoire de l'utilisateur
    $config.permission = $config.Account, $config.modify, $config.InheritanceFlags, $config.PropagationFlags, $config.AccessControl
    $config.Accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule $config.permission 
    $acl.SetAccessRule($config.AccessRule)
    Set-ACL -Path $config.HomeLocation $acl
    $config.ShareDirpermission = $config.Account, $config.ReadAndExecute, $config.InheritanceFlags, $config.PropagationFlags, $config.AccessControl 
}
}
function main () {
# On importe notre fichier de config 
    $configfile = $args[0]

    if (Test-Path -Path $configfile) {
    } 
    else {
        Write-Host ("File " + $configfile + " does not exists")
        exit 1
    }
    try {
        $config = Import-PowerShellDataFile -Path $configfile
    }
    catch {
        Write-Host $_.Exception
    }
# On appel notre fonction CreateUser  
    CreateUser $config
}
#On verifie que notre fichier de conf est bien donné en argument
if ($args.Length -gt 0) {
    main $args[0]
} 
else {
    Write-Host ("Arguments not fully specified")
    Write-Host ("Specify config file as argument like: DomainDeploymentTool.ps1 <config file name>")
    exit 1
}