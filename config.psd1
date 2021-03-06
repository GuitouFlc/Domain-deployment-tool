@{
    #Ajout des fonctionnalites au serveur
    features = @(
        'DHCP',
        'AD-Domain-Services',
        'Print-Server',
        'File-Services',
        'Internet-Print-Client',
        'wds-deployment'
    )
    
    #conf Domain
    dnsdomain = "acme.loc"
    netbiosdomain = "ACME"
    recoverypassword = "Password2019"
    
    #conf DHCP
    dhcpName = "dhcp.acme.loc"
    dhcpIP = "192.168.50.200"
    dhcpconfigs = @(
        @{
            domain = "Paris"
            scopid = "192.168.50.0"
            startrange = "192.168.50.201"
            endrange = "192.168.50.230"
            subnet = "255.255.255.0"
        },
        @{
            domain = "Granville"
            scopid = "192.168.1.0"
            startrange = "192.168.1.1"
            endrange = "192.168.1.254"
            subnet = "255.255.255.0"
        }  
    )
    
    #conf Printer
    PrintName = "Cups PDF"
    Driver = "MS Publisher Color Printer"
    Port = "http://192.168.50.210:631/printers/IMPRIMANTE_PDF"
    
    #conf smbshare
    ServerDrive = "C:"
    ShareDir = "SHARE"
    GroupUsers = "Users"
    GroupAdmin = "Administrators"

    #conf User HomeDirectory
    ServerName = "Server19"
    Drive = "H:"
    Path = "SHARE"
    Domain = "ACME"

    #conf Import CSV
    DefaultUserPass ="Password2019"

    #OU Path
    OUPath = "OU=ACME,DC=acme,DC=loc"
}
