<# Attention lors de la jonction d'un poste au domain il faudra utilisez le compte "Administrateur"
Le montage des dossier utilisateurs dans le cas présent sont fait à partir du serveur de fichier
comme l'ensemble des manipulations
#>
function CreateUser() {
# On appel notre fichier de conf 
    $config = $args[0]

Import-csv "C:\Users\Administrator\Documents\Domain-deployment-tool\P05_Admin-test.csv" | ForEach-Object {
$firstname = $_.Prenom
$surname = $_.Nom
$samAccName = $firstname + " " + $surname
$DefaultPassword = (ConvertTo-SecureString $config.DefaultUserPass -AsPlainText -Force)

$UserOUPath = "OU=" + $_.Departement + "," + $config.OUPath
$completePath = $config.ServerDrive + "\" + $config.ShareDir + "\" + $_.Departement
$HomeLocation = $config.ServerDrive + "\" + $config.Path + "\" + $_.Departement + "\" + $SamAccName
$HomeFolder = "\\" + $env:Computername + "\" + $config.Path + "\" + $_.Departement + "\" + $SamAccName

## on vient créer nos OU si necessaire
try{
    New-ADOrganizationalUnit -Name $_.Departement -Path $config.OUPath -ErrorAction Stop
    }
    catch [System.ServiceModel.FaultException]{
        Write-Host $_
        Write-Host "OU Already exist"
    }   
## on vient créer nos Groupes si necessaire
try{
    New-ADGroup -Name $_.Departement -SamAccountName $_.Departement -Path $UserOUPath -GroupCategory Security -GroupScope Global -ErrorAction Stop
    }
    catch [System.ServiceModel.FaultException]{
        Write-Host $_
        Write-Host "Group Already exist"
    }   
        try{
#On vient créer notre utilisateur en forçant le renouvellement du mot de passe lors de l'identification
            New-ADUser -name $samAccName -GivenName $firstname -surname $surname `
            -AccountPassword $DefaultPassword `
            -SamAccountName $samAccName -city $_.site `
            -Title $_.Fonction -Department $_.Departement -MobilePhone $_.Mobile -OfficePhone $_.Tel2 `
            -EmailAddress $_.email -Office $_.Site -Path $UserOUPath
            Write-Host $samAccName "is been create"
            set-ADUser -identity $samAccName -ChangePasswordAtLogon $true
            Write-Host "New Password will be ask at first log" 
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
#On met notre User dans son groupe
    Add-ADGroupMember -identity $_.Departement -Members $samAccName  

## Add home folder on 'H:'
    $Users = Get-ADUser -Filter *
    $Users | ForEach-Object {
            if($samAccName -eq $_.SamAccountName){
                Set-ADUser -Identity $samAccName -HomeDirectory $HomeFolder -HomeDrive $config.Drive
                Write-Host $samAccName" Name match with Current User"
                Write-Host "Home folder for " $samAccName" is now available on " $config.Drive
                Write-Host "Network Location : " $HomeFolder
            }  
        } 
        Write-Host $_.Exception

#On configure nos variable pour la suite (gestion des droit / ACL)
            $Modify = [System.Security.AccessControl.FileSystemRights]"modify"
            $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags] 1,2
            $PropagationFlags = [System.Security.AccessControl.PropagationFlags] 0
            $AccessControl = [System.Security.AccessControl.AccessControlType]"Allow"
            
#On Verifie que le dossier existe si ce n'est pas le cas on vient le créer
            if(Test-Path -path $HomeLocation){
                Write-Host $HomeLocation" exist"
            }
            else{
                New-Item -ItemType directory -Path $completePath -Name $samAccName -ErrorAction Stop
            } 
## On définit de nouveaux droits pour notre utilisateur sur le dossier de partage et sur son dossier   
    $Account = $config.Domain + "\" + $samAccName  
                
    $acl = Get-Acl -Path $completePath
# On applique les droit sur le repertoire de l'utilisateur
    $permission = $Account, $modify, $InheritanceFlags, $PropagationFlags, $AccessControl
    $Accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission 
    $acl.SetAccessRule($AccessRule)
    Set-ACL -Path $HomeLocation $acl
    #$ShareDirpermission = $Account, $ReadAndExecute, $InheritanceFlags, $PropagationFlags, $AccessControl 
}
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
        Write-Host $configfile "import success" -BackgroundColor Green 
       
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