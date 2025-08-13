<#  =====================================================================================
    DESCRIPTION
        This script was created to quickly install a specific MSI across multiple Windows hosts
        The installer MSI will always be placed locally in C:\TEMP\ on each specified Windows host

    NOTES
        Install path is not a variable due to limitations of Invoke-Command in combination with msiexec, so the MSI is executed from C:\TEMP\$File
        Has some inbuilt sleep timers to wait for the MSI file to be copied or installed 
        Seperated the copy loop and the install loop as sometetimes it wouldn't run the MSI for some reason (even with a sleep timer after the copy)
       

    FUNCTIONS
        1. Copies the MSI to the computers local directory
            1.1 To C:\TEMP\$File or \\$Comp\C$\Temp\$File
            1.2 This step is required as you can't authenticate to something (e.g. a file server) through a remote session (called a 'double-hop')

        2. Installs the MSI from the above directory on each Windows host
           2.1 Logs are exported to \\$Comp\C$\TEMP\Installer-$Comp\
            

        3. Checks registry to see if the MSI was installed successfully 
            3.1 HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
            3.2 HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

        4. Outputs a table with results, including additional information from registry for the installed MSI, if installed successfully

    =====================================================================================
    PREREQUISITES
        1. Access to the respective file server or path to copy the MSI from
            1.1 With your domain admin or local admin account

        2. Access to the Windows host with your domain admin or local admin account
            2.2 You may have to RDP to the server and run this script from there due to restrictions on domain admin or local admin accounts, depending on where it's run from or on what host
    =====================================================================================#



#===================================VARIABLES TO SET=====================================#>

$Computers = "", "" #List of computers or hosts for the MSI to be installed on
$CopyPath = "\\***********\googlechromestandaloneenterprise64.msi" #Where the MSI is being copied from (include the file name and .msi) will be copied to each Windows host
$File = "googlechromestandaloneenterprise64.msi" #Name of the MSI to be installed, include .msi
$AppName = "chrome" #Input part of the name of the installed app to search for in registry - e.g. check, 7-z, Microsoft, Manager, etc.

#========================================================================================#


#Save credentials to PowerShell session so it's not required to be entered every time - Saved as a secure string as part of PSCredential
IF ($Credentials -isnot [PSCredential]) {
    $Credentials = Get-Credential
}


#========================================================================================#
#Copy $File to each $Comp
#Copy from $CopyPath to C:\TEMP\ on each $Comp
#----------------------------------------------------------------------------------------#
ForEach ($Comp in $Computers) {
    $TestPath = Test-Path -Path "\\$comp\C$\TEMP\$File"
    cd "\\$comp\C$\temp\"

    IF ($TestPath -eq $False){
        Write-Host "Copying file from $CopyPath to \\$Comp\C$\TEMP\" -ForegroundColor Yellow
        Copy-Item -Path "$CopyPath" -Destination "\\$Comp\C$\TEMP\"
        Start-Sleep -Seconds 8
    }
    ELSE{
        Write-Host "$File already exists on \\$Comp\C$\TEMP\" -ForegroundColor Yellow
    }
}
''


#========================================================================================#
#Install $File on each $Comp
#Install directory is  C:\TEMP\$File on each $Comp
#----------------------------------------------------------------------------------------#
ForEach ($Comp in $Computers) {
    $LogFile = "\\$Comp\C$\TEMP\Installer-$Comp"
    $TestPath = Test-Path -Path "\\$comp\C$\TEMP\$File"

    IF ($TestPath -eq $True){
        Write-Host "Attempting to install $File on $Comp" -ForegroundColor Yellow
        Invoke-Command -AsJob -ComputerName $comp -Credential $Credentials -scriptblock `
        {start-process  msiexec -ArgumentList "/i C:\TEMP\googlechromestandaloneenterprise64.msi /quiet /log $Using:LogFile.log" -wait} | out-null       #File name required to be changed here as well
    }
    ELSE{
        Write-Host "Couldn't find $File in \\$comp\C$\TEMP\  ... Exiting" -ForegroundColor Red    
    }
}


''
Write-host "Waiting 40 seconds for MSI install(s)"
Start-Sleep -Seconds 40
''


#========================================================================================#
#Check if $File was installed succesfully for each $Comp
#Looks in registry to see if it exists
#----------------------------------------------------------------------------------------#
#$AppName = Read-Host "Input part of the name of the installed app to search for in registry - e.g. check, 7-z, Microsoft, Manager, etc." 
#''

$Results = ForEach ($Comp in $Computers) {
    $LogFile = "\\$Comp\C$\TEMP\Installer-$Comp"
    $TestInstall = Invoke-Command –ComputerName $Comp –ScriptBlock {Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'} | Where-Object -Property DisplayName -like "*$AppName*"
    $TestInstall   

    IF ($TestInstall -eq $Null) {
        Write-Host "$Comp does not have $File installed - Logs exported to $LogFile.log (if the MSI exists locally)" -ForegroundColor Red
                   "$Comp does not have $File installed" #Used for the final table output
    }
    ELSE{
        Write-Host "$File successfully installed on $Comp - Logs exported to $LogFile.log"  -ForegroundColor Green 
        $Tableoutput = $Results
    }
}



''
#========================================================================================#
#Final output as a table 
#Information about the install is pulled from registry on each $Comp
#========================================================================================#

$Tableoutput = $Results | Format-Table PSComputerName, DisplayVersion, PSDrive, DisplayName, PSChildName, PSParentPath -AutoSize #-GroupBy PSParentPath
$Tableoutput 
