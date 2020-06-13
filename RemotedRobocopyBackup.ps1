#New-EventLog -LogName Application -Source "RobocopyBackup"

#variable
#recuperation de la liste des machines de l'AD + filtrage par nom
$remote= Get-AdComputer -Filter * | Select-Object Name
ForEach ($client in $remote){
    #si le nom contient "client"
    if ($Client.Name -like "*client*"){
        $Machine = $Client.Name
        #on verifie que notre client est disponible "en ligne"
        $OnlineTest = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Machine -Quiet
        Write-Host "Verification de disponibilite de " $Client.Name
        #si il est dispo on execute robocopy et on enregistre l'evennement avec l'id 1 dans le journal windows
        if ($OnlineTest -eq $true){
                Write-host "$Machine est disponible"
                Write-Host "Debut de la copie de $RemoteDir vers $BackupDir"
                robocopy \\$Machine\C$\Users\Administrateur C:\SAV\$Machine /MIR /XA:H /W:0 /R:1 /REG /FFT /s
                Write-EventLog -ComputerName $env:COMPUTERNAME -LogName Application -Source "RobocopyBackup" -EventId 1 -Message "RobocopyBackup Success for $Machine"
                }
        
        #si il n'est pas dispo on enregistre l'evennement dans le journal windows (id 2 type Warning)
        if ($OnlineTest -eq $false){
            Write-host "$Machine est indisponible"
            Write-Host "Copie Impossible"
            Write-EventLog -ComputerName $env:COMPUTERNAME -LogName Application -Source "RobocopyBackup" -EntryType Warning -EventId 2 -Message "RobocopyBackup n'as pas pu s'executer, $Machine est injoignable"
            
        }
    }
}