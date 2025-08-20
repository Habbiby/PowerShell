#Used for the progress bar and timer
$PCount = 0
$TCount = 0
$StartTime = Get-Date

 
#===================================VARIABLES TO SET=====================================#

#Collects list of computers you want to search from a file - empty lines are ignored 
#Make sure no tabs or spaces are after the PC name in the .txt file
#$Computers = Get-Content -ErrorAction Stop -Path "C:\Temp\ComputerAssetList.txt" | Where { $_ }
#$Computers = Get-Content -ErrorAction Stop -Path "C:\Temp\ComputerAssetListALL.txt" | Where { $_ }
$Computers = ""



#Name of application you're searching for - automatically wildcarded on each side
$Application = "Oracle"

#========================================================================================#


#Tests if Powershell is being ran as admin
$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
IF ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $True){
    
    #Loop which goes through the list of $computers and runs the below for each $Comp - $Results variable used for the final table after going through $Computers list
    $Results = Foreach ($Comp in $Computers) {
        $Ping = Test-Connection -ComputerName $Comp -count 2 -Quiet
        
        #If the ping to the computer is successful, continues the script
        IF ($Ping -eq $True) { 
        
            #Required otherwise the IP for each tested $Comp would output twice
            $GetIP = Test-Connection -ComputerName $Comp -Count 1    
            Write-Host "Ping to $Comp successful - IP:"($GetIP.IPV4Address) -ForegroundColor Green 

            #Hides the TCP test progress bar
            $ProgressPreference = "SilentlyContinue"

            #Tests TCP port 5985 - required to remotely 'Invoke-Command'
            $TestPort = Test-NetConnection -ComputerName $Comp -Port 5985 -ErrorAction SilentlyContinue -WarningAction 0 

            #Re-enables the progress bar for the overall script
            $ProgressPreference = "Continue"

            #If Test-NetConnection returns true the remote command will be sent and properties collected
            IF ($TestPort.TcpTestSucceeded -eq $True){

                #Collects item properties from registry where the object includes $Application
                $RegValues = Invoke-Command –ComputerName $Comp –ScriptBlock `
                    {Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'} | `
                    Where-Object -Property DisplayName -like "*$Application*" 
                $RegValues

                #If collecting the item properties returns nothing this will run - it only returns a value if the application is found
                IF ($RegValues -eq $Null) {

                    Write-Host "$Comp does not have that application installed" -ForegroundColor Yellow
                    "$Comp does not have $Application installed" #Used for the final table output

                }ELSE{
                    Write-Host "$Application found on $Comp"              
                }
             }

            #If the test on TCP port 5985 failed, it runs a script to enable PSRemoting (which is WinRM) then collects properties
            #Sometimes TcpTestSucceeded returns as true, but remote command does not work - usually because the WinRM services isn't running or local firewall rules haven't been updated?
            IF ($TestPort.TcpTestSucceeded -ne $True){
                
                <#
                Enables PSRemoting / WinRM using DCOM - DCOM = allows two different app components on different Windows machines to interact with each other (uses TCP port 135 which is already open) 
                "Invoke-Command" can only use TCP port 5985(HTTP) or 5986(HTTPS)
                CimSession uses 5985 by default but is overridden to 135 by setting -Protocol DCOM
                #> 
                
                Write-Host "Trying to enable WinRM / PSRemoting on $comp"
                $SessionArgs = @{
                ComputerName  = "$Comp"
                SessionOption = New-CimSessionOption -Protocol DCOM
                            }
                $MethodArgs = @{
                ClassName     = 'Win32_Process'
                MethodName    = 'Create'
                CimSession    = New-CimSession @SessionArgs
                Arguments     = @{
                CommandLine = "powershell Start-Process powershell -ArgumentList 'Enable-PSRemoting -Force'"
                                }
                            }
                Invoke-CimMethod @MethodArgs
                ##############################
 
                #Collects the item properties from registry where the objects includes the specified application
                $RegValues = Invoke-Command –ComputerName $Comp –ScriptBlock `
                    {Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'} | `
                    Where-Object -Property DisplayName -like "*$Application*" 
                $RegValues
                        
                        #If collecting the item properties returns nothing this will run - it only returns a value if the application is found
                        IF ($RegValues -eq $null) {

                            Write-Host "$Comp does not have $Application installed, or the TCP connection failed" -ForegroundColor Yellow
                            "$Comp does not have $Application installed, or the TCP connection failed" #Used for the final table output

                        }ELSE{
                            Write-Host "$Application found on $Comp"  
                                        }
    }
        }
        ELSE {
         Write-Host "Ping to $Comp failed" -ForegroundColor Red
            "$Comp was not reachable" #Used for the final table output
        }
    #Progress bar, percent completed and time remaining
    $PCount++
    $TCount++
    $ElapsedTime = (Get-Date) - $StartTime
    $timeLeft = [TimeSpan]::FromMilliseconds((($ElapsedTime.TotalMilliseconds / $TCount) * ($Computers.Count - $TCount)))
    Write-Progress -activity "Collecting data..." `
        -status "Scanned: $PCount of $($Computers.Count) Time Remaining: $($timeLeft.Minutes) Minutes, $($timeLeft.Seconds) Seconds" `
        -PercentComplete (($PCount / $Computers.Count)  * 100) `
        -CurrentOperation "Completed: $([math]::round((($PCount / $Computers.Count))  * 100,3))%"
    }

#Tests the output path, makes the directory if it fails
$PathTest = Test-Path -Path "C:\Temp\GUIDs\"
IF ($PathTest -eq $False){
    New-Item -Path "C:\TEMP\" -Name "GUIDs" -ItemType Directory
}

#Sorts and formats the $Results from the ForEach loop - Exports the list to a .txt document then displays the results in the console
#Seperate table for each registry path (PSParentPath)
Write-Host "Results exported to C:\Temp\GUIDs\GUIDs.txt"
$Tableoutput = $Results | Sort-Object PSComputerName,PSChildName -Descending | Format-Table PSComputerName, DisplayVersion, PSDrive, DisplayName, PSChildName, PSParentPath -AutoSize #-GroupBy PSComputerName
$Tableoutput | Out-File -FilePath "C:\Temp\GUIDs\GUIDs.txt"
$Tableoutput
}

#Runs if the user running Powershell is not an admin
Else{
    Write-Host "Run this script as administrator and try again" -ForegroundColor Yellow
}



<#
##########################################
Other commands to run if WinRM is failing:
##########################################

==========================================
Admin command prompt on the $comp:
==========================================
winrm enumerate winrm/config/listener                #ListeningOn should contain local IP and current IP of $comp
winrm /quickconfig                                   #Locally sets up winrm configuration (Sets service to start + automatic start, and opens firewall port 5895 for WinRM )

==========================================
Powershell:
==========================================
Test-NetConnection -ComputerName $Comp -Port 5985    #Tests connection to $comp via port 5985
Test-WSMan                                           #Result back means successful
Get-Item WSMan:\localhost\Client\TrustedHosts        #Lists trusted hosts
Get-Service -Name winrm | Select Status              #Shows if the WinRM service is running
Get-ChildItem WSMan:\localhost\Client\DefaultPorts   #Shows ports for WinRM
Get-ChildItem WSMan:\localhost\Listener              #Shows what ports are setup to listen on
Enable-PSRemoting -Force                             #Enables PowerShell remoting (Same as winrm /quickconfig)




#>
