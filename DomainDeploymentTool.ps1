# Enable features
function enablefeatures () {
    foreach ($feature in $config.features) {
        Add-WindowsFeature -Name $feature -IncludeManagementTools
        Write-Host $feature" feature activation OK"
    }
}
## Active directory
function activedirectory() {
    $config = $args[0]
    try {
        Install-ADDSForest -DomainName $config.dnsdomain -DomainMode WinThreshold -ForestMode WinThreshold -DomainNetbiosName $config.netbiosdomain -InstallDns -SafeModeAdministratorPassword $config.safepassword -Confirm -Force -ErrorAction Stop
        Write-Host "AD config OK"
    }
    catch [System.Management.Automation.ParameterBindingException]{
        Write-Host $_
        Write-Host "Error occured"
    }
    catch {
        Write-Host $_.Exception
    }
    Write-Host "end of Active Directory configuration"     
}

## DHCP
function dhcp () {
    $config = $args[0]
    
    $DHCPName = $env:COMPUTERNAME + "." + $config.dnsdomain 
    
    Add-DhcpServerInDC -DnsName $config.dhcpName -IPAddress $config.dhcpIP
    foreach ($dhcpconfig in $config.dhcpconfigs) {
        try {
            Add-DhcpServerv4Scope -Name ($dhcpconfig.domain + '.' + $config.dnsdomain) -StartRange $dhcpconfig.startrange -EndRange $dhcpconfig.endrange -SubnetMask $dhcpconfig.subnet
            
            Write-Host $dhcpconfig.domain " configuration OK"
        }
        catch [Microsoft.Management.Infrastructure.CimException] {
            Write-Host $_
        }
        finally {
            Write-Host ("Updating " + $dhcpconfig.scopid + " zone")
            Set-DhcpServerv4Scope -ScopeId $dhcpconfig.scopid -Name ($dhcpconfig.domain + '.' + $config.dnsdomain) -StartRange $dhcpconfig.startrange -EndRange $dhcpconfig.endrange
        }        
    }
    Add-DhcpServerSecurityGroup -ComputerName $DHCPName
    netsh DHCP add securitygroups
    restart-Service dhcpserver
    Write-Host "end of dhcp configuration"
}

## Add Printer (Cups PDF in this case)
function AddPrint(){
    $config = $args[0]
    try {
        Add-PrinterDriver -Name $config.Driver
        Add-Printer -Name $config.PrintName -DriverName $config.Driver -PortName $config.Port -Shared -ShareName $config.PrintName -Published -ErrorAction Stop
        Write-Host $config.PrintName " configuration OK"
    }
    catch [Microsoft.Management.Infrastructure.CimException]{
        Write-Host $_
    }
    Write-Host "end of Print Server configuration"
}

## SMB Share
function sharefolder() {
    $config = $args[0]
    $folder = $config.ServerDrive + "\" + $config.ShareDir
       
    if (Test-Path -Path $folder) {
        Write-Host ("Folder " + $folder + " already exist")
    } else {
        mkdir $folder
        Write-Host $folder " is been create" 
    }
    $acl = Get-Acl $folder
    $acl.SetAccessRuleProtection($true, $false)

    #Grant Admin FullControl
    $Administrators = [System.Security.Principal.NTAccount] "Administrateurs"
    $permission = $Administrators,"FullControl","ObjectInherit,ContainerInherit","None","Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.AddAccessRule($accessRule)

    #Grant Everyone Write and ReadAttribute
    $Everyone = [System.Security.Principal.NTAccount] "Utilisateurs du domaine"
    $permission = $Everyone,"ListDirectory","ObjectInherit,ContainerInherit","None","Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.AddAccessRule($accessRule)
    $acl | Set-Acl $folder

    try {
        New-SmbShare -Name $config.ShareDir -Path $folder -ChangeAccess Everyone -ErrorAction Stop
        Write-Host $config.ShareDir " is now configured on "$config.ServerDrive
    }
    catch [Microsoft.Management.Infrastructure.CimException] { 
        Write-Host $_      
    }
    Write-Host "end of SMB Share configuration"    
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

    $config.safepassword = ConvertTo-SecureString -String $config.recoverypassword -AsPlainText -Force

    enablefeatures $config
    activedirectory $config
    dhcp $config
    AddPrint $config
    sharefolder $config
}

if ($args.Length -gt 0) {
    main $args[0]
} else {
    Write-Host ("Arguments not fully specified")
    Write-Host ("Specify config file as argument like: DomainDeploymentTool.ps1 <config file name>")
    exit 1
}
