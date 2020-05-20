

$safepassword = ConvertTo-SecureString -String "95MesCouilles" -AsPlainText -Force

Add-WindowsFeature AD-Domain-Services

Install-ADDSForest -DomainName paul.loc -DomainNetbiosName PAUL -InstallDns -SafeModeAdministratorPassword $safepassword -Confirm -Force