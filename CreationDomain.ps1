$dnsdomain = "paul.loc"
$netbiosdomain = "PAUL"

$safepassword = ConvertTo-SecureString -String "95MesCouilles" -AsPlainText -Force

Add-WindowsFeature AD-Domain-Services

Install-ADDSForest -DomainName $dnsdomain -DomainNetbiosName $netbiosdomain -InstallDns -SafeModeAdministratorPassword $safepassword -Confirm -Force