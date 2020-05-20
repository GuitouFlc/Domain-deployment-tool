# Enable features
function enablefeatures () {
    foreach ($feature in $config.features) {
        Add-WindowsFeature -Name $feature -IncludeManagementTools
    }
}

## Active directory
function activedirectory() {
    $config = $args[0]
    try {
        Install-ADDSForest -DomainName $config.dnsdomain -DomainNetbiosName $config.netbiosdomain -InstallDns -SafeModeAdministratorPassword $config.safepassword -Confirm -Force
    }
    catch [System.Management.Automation.ParameterBindingException] {
        Write-Host $_.Exception
        Write-Host "Error occured"
    }
}

## DHCP
function dhcp () {
    $config = $args[0]
    foreach ($dhcpconfig in $config.dhcpconfigs) {
        try {
            Add-DhcpServerv4Scope -Name ($dhcpconfig.domain + '.' + $config.dnsdomain) -StartRange $dhcpconfig.startrange -EndRange $dhcpconfig.endrange -SubnetMask $dhcpconfig.subnet
        }
        catch [Microsoft.Management.Infrastructure.CimException] {
            Write-Host $_
        }
        finally {
            Write-Host ("Updating " + $dhcpconfig.scopid + " zone")
            Set-DhcpServerv4Scope -ScopeId $dhcpconfig.scopid -Name ($dhcpconfig.domain + '.' + $config.dnsdomain) -StartRange $dhcpconfig.startrange -EndRange $dhcpconfig.endrange
        }
    }
}

function main () {
    ## Config import
    $configfile = $args[0]

    if (Test-Path -Path $configfile) {
    } else {
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
}

if ($args.Length -gt 0) {
    main $args[0]
} else {
    Write-Host ("Arguments not fully specified")
    Write-Host ("Specify config file as argument like: CreationDomain.ps1 <config file name>")
    exit 1
}
