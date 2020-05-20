## Import de la configuration

$config = Import-PowerShellDataFile -Path "config.psd1"
$safepassword = ConvertTo-SecureString -String $config.recoverypassword -AsPlainText -Force

## Active directory
Add-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools

try {
    Install-ADDSForest -DomainName $config.dnsdomain -DomainNetbiosName $config.netbiosdomain -InstallDns -SafeModeAdministratorPassword safepassword -Confirm -Force
}
catch [TestFailedException] {
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