function CreateUser() {
    $config = $args[0]
## Attention lors de la jonction d'un poste au domain il faudra utilisez le compte "Administrateur"

Import-csv "C:\Users\Administrator\Documents\Domain-deployment-tool\P05_Admin-test.csv" | ForEach-Object {
$givenName = $_.Prenom
$surname = $_.Nom
$samAccName = $givenName + " " + $surname

$config.completePath = $config.ServerDrive + "\" +$config.ShareDir
$config.HomeLocation = $config.ServerDrive + "\" + $config.Path + "\" + $SamAccName
$config.HomeFolder = "\\" + $env:Computername + "\" + $config.Path + "\" + $SamAccName
$config.DefaultPassword = (ConvertTo-SecureString 'Password2019' -AsPlainText -Force)
##debug line
#Write-Host $SamAccName
  
        try{
            New-ADUser -name $samAccName -GivenName $givenName -surname $surname `
            -AccountPassword $config.DefaultPassword -ChangePasswordAtLogon $true `
            -SamAccountName $samAccName -city $_.site `
            -Title $_.Fonction -Department $_.Departement -MobilePhone $_.Mobile -OfficePhone $_.Tel2 `
            -EmailAddress $_.email -Office $_.Site
            
            Write-Host $samAccName "is been create"
        }
## si le compte existe deja on s'arette
        catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException]{
            Write-Host $_
        }
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
            #else{
            #    Write-Host $_.SamAccountName" Name not match with Current User"    
            #}  
        } 
        Write-Host $_.Exception   
        
#$config.Fullcontrol= [System.Security.AccessControl.FileSystemRights]"FullControl"
            $config.Modify = [System.Security.AccessControl.FileSystemRights]"modify"
            $config.ReadAndExecute = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute"
            $config.InheritanceFlags = [System.Security.AccessControl.InheritanceFlags] 1,2
            $config.PropagationFlags = [System.Security.AccessControl.PropagationFlags] 0
            $config.AccessControl = [System.Security.AccessControl.AccessControlType]"Allow"
            
### Verification de la présence du dossier
            if(Test-Path -path $config.HomeLocation){
                Write-Host $config.HomeLocation" already exist"
            }
            else{
                New-Item -ItemType directory -Path $config.completePath -Name $samAccName -ErrorAction Stop
            } 
        
## On définit de nouveaux droits pour notre utilisateur sur le dossier de partage et sur son dossier   
    $config.Account = $config.Domain + "\" + $samAccName 
## Debug line
    Write-Host $samAccName 
    Write-Host $config.Account
    Start-Sleep 3 
          
## debug line >      
    $acl = Get-Acl -Path $config.completePath
       
## USER DIRECTORY
    $config.permission = $config.Account, $config.modify, $config.InheritanceFlags, $config.PropagationFlags, $config.AccessControl
    $config.Accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule $config.permission 
    $acl.SetAccessRule($config.AccessRule)
    Set-ACL -Path $config.HomeLocation $acl

    $config.ShareDirpermission = $config.Account, $config.ReadAndExecute, $config.InheritanceFlags, $config.PropagationFlags, $config.AccessControl 
}
}

function main () {
    ## Config import
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
  
    CreateUser $config
}

if ($args.Length -gt 0) {
    main $args[0]
} 
else {
    Write-Host ("Arguments not fully specified")
    Write-Host ("Specify config file as argument like: DomainDeploymentTool.ps1 <config file name>")
    exit 1
}