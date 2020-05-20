$dnsdomain = "paul.loc"
$netbiosdomain = "PAUL"
$recoverypassword = "Password95"

$safepassword = ConvertTo-SecureString -String $recoverypassword -AsPlainText -Force

Add-WindowsFeature AD-Domain-Services

Install-ADDSForest -DomainName $dnsdomain -DomainNetbiosName $netbiosdomain -InstallDns -SafeModeAdministratorPassword $safepassword -Confirm -Force