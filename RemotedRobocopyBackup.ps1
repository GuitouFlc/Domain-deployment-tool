    #on crée un Event pour notre observateur d'evennement
    try{
        New-EventLog -LogName Application -Source "RobocopyBackup" -ErrorAction stop
    }
    # s'il existe deja on le notifie avant de passer à la suite
    catch [System.InvalidOperationException]{
        Write-Host $_
        Write-EventLog -ComputerName $env:COMPUTERNAME -LogName Application -Source "RobocopyBackup" -EntryType Warning -EventId 3 -Message "Avertissement : La source RobocopyBackup est deja inscrite sur l'ordinateur $env:COMPUTERNAME "
    }

    #On met en place la tache planifiée pour l'execution du script
    $backupHour = "9:00pm"
    $ScriptLocation = "c:\Users\Administrateur\Documents\Domain-deployment-tool\RemotedRobocopyBackup.ps1"
    $Trigger = New-ScheduledTaskTrigger -At $backupHour -Daily
    $User = "NT Authority\SYSTEM"
    $Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $ScriptLocation
    Register-ScheduledTask -TaskName "RobocopyBackup" -Trigger $Trigger -user $User -Action $action -RunLevel Highest -Force

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
                Write-EventLog -ComputerName $env:COMPUTERNAME -LogName Application -Source "RobocopyBackup" -EntryType Warning -EventId 2 -Message " RobocopyBackup n'as pas pu s'executer, $Machine est injoignable"
            }
        }
    }
