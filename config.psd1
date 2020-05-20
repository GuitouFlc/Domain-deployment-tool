@{
    features = @(
        'DHCP',
        'AD-Domain-Services',
        'Print-Server'
    )
    dnsdomain = "paul.loc"
    netbiosdomain = "PAUL"
    recoverypassword = "Password95"
    dhcpconfigs = @(
        @{
            domain = "granville"
            scopid = "10.10.10.0"
            startrange = "10.10.10.1"
            endrange = "10.10.10.254"
            subnet = "255.255.255.0"
        },
        @{
            domain = "paris"
            scopid = "10.10.20.0"
            startrange = "10.10.20.1"
            endrange = "10.10.20.254"
            subnet = "255.255.255.0"
        },
        @{
            domain = "rennes"
            scopid = "10.10.30.0"
            startrange = "10.10.30.1"
            endrange = "10.10.30.254"
            subnet = "255.255.255.0"
        }
    )
    users = @(
        @{
            name = "guitou1"
        },
        @{
            name = "guitou2"
        }
    )
}