## Config import

$configfile = "config.psd1"

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

$safepassword = ConvertTo-SecureString -String $config.recoverypassword -AsPlainText -Force

## Active directory
Add-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools

try {
    Install-ADDSForest -DomainName $config.dnsdomain -DomainNetbiosName $config.netbiosdomain -InstallDns -SafeModeAdministratorPassword safepassword -Confirm -Force
}
catch [System.Management.Automation.ParameterBindingException] {
    Write-Host $_.Exception
    Write-Host "Error occured"
}

## DHCP
Add-WindowsFeature -Name "DHCP" -IncludeManagementTools

## Creating DHCP zones
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