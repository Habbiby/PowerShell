<# ==========================================================================
    DESCRIPTION
    This script was created for the Service Desk Kiosk machines
    Functions:
        1. Disables windows key
        2. Creates a batch file on public desktop to force restart Edge in Kiosk Mode
        3. Creates 2 Scheduled Tasks to launch edge in Kiosk Mode, and another to restart it when idle for 4 minutes
            3.1 OnIdle is hardcoded to trigger after four minutes in Windows 10, it will only trigger once per idle
        4. Deletes or changes startup settings for Microsoft Teams to disable it
        5. Auto logs in as SD.Kiosk when restarted or booted
    ==========================================================================

#>
#1=============================================================================
#Disable Windows key registry setting
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "Scancode Map" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x5B,0xE0,0x00,0x00,0x5C,0xE0,0x00,0x00,0x00,0x00)) -Type Binary -Force

#2=============================================================================
#Create backup batch file on desktop for launching kiosk mode
$FilePath = "C:\Users\Public\Desktop\EdgeKioskMode.bat"

#Check File Exists
if (Test-Path "$FilePath") {
    Write-host "File '$FilePath' already exists!" -f yellow
}
Else {
     #Create a new file
	 New-Item -Path $FilePath -ItemType "File"
	 Add-Content -Path $FilePath -Value "taskkill.exe /f /im msedge.exe"
	 Add-Content -Path $FilePath -Value '"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" ************* --kiosk --new-window'
     Out-File "$FilePath" -Append -Encoding Ascii
	     Write-host "New File '$FilePath' Created!" -f Green
}

#3=============================================================================
#Creating Scheduled Tasks to launch edge in Kiosk Mode, and to restart it when idle for 4 minutes
$IdleExists = Get-ScheduledTask | Where-Object {$_.TaskName -like "IdleKioskRestart"}
$KioskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like "EdgeKioskMode"}

$StartIdle = Get-ScheduledTask |  Where {$_.TaskName -eq 'IdleKioskRestart'} | where {$_.state -eq 'Ready' -or $_.State -eq 'Queued' -or $_.State -eq 'Running'}
$StartKiosk = Get-ScheduledTask | Where {$_.TaskName -eq 'EdgeKioskMode'} | where {$_.state -eq 'Ready' -or $_.State -eq 'Running'} 


IF($IdleExists){
    IF(!($StartIdle)){
       Enable-ScheduledTask -TaskName IdleKioskRestart
       Start-ScheduledTask -TaskName IdleKioskRestart
       } 
}
ELSE{
    Register-ScheduledTask -xml (Get-Content "C:\Users\SD.Kiosk\*********\IdleKioskRestart.xml" | Out-String) -TaskName "IdleKioskRestart" -TaskPath "\"
    Start-ScheduledTask -TaskName IdleKioskRestart
}

IF($KioskExists){
   IF(!($StartKiosk)){
       Enable-ScheduledTask -TaskName EdgeKioskMode
       Start-ScheduledTask -TaskName EdgeKioskMode
       } 
}
ELSE{
    $trigger = New-ScheduledTaskTrigger -AtLogOn 
    $action = New-ScheduledTaskAction -Execute '"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"' -Argument "https://************.au --kiosk"
    $user = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
    Register-ScheduledTask -TaskName EdgeKioskMode -Principal $user -Trigger $trigger -Action $action
    Start-ScheduledTask -TaskName EdgeKioskMode
}




#4=============================================================================
<#Deleting and changing Teams autostart settings
NOTE: This is likely only a temporary fix as it seems that MS Teams changes
some of these options between versions, everyone online seems to have to redo it
about every few months #>
$ErrorActionPreference= 'silentlycontinue'
 
# Delete Reg Key
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regKey = "com.squirrel.Teams.Teams"
 
Remove-ItemProperty $regPath -Name $regKey
 
# Teams Config Path
$teamsConfigFile = "$env:APPDATA\Microsoft\Teams\desktop-config.json"
$teamsConfig = Get-Content $teamsConfigFile -Raw
 
if ( $teamsConfig -match "openAtLogin`":false") {
    break
}
elseif ( $teamsConfig -match "openAtLogin`":true" ) {
    # Update Teams Config
    $teamsConfig = $teamsConfig -replace "`"openAtLogin`":true","`"openAtLogin`":false"
}
else {
    $teamsAutoStart = ",`"appPreferenceSettings`":{`"openAtLogin`":false}}"
    $teamsConfig = $teamsConfig -replace "}$",$teamsAutoStart
}
 
$teamsConfig | Set-Content $teamsConfigFile
 
Write-Host "`nDone!`n"

#5=============================================================================
#Setting the machine to auto login as SD.Kiosk
New-ItemProperty -Name AutoAdminLogon -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Value 1 -Type String -force
New-ItemProperty -Name DefaultUserName -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Value "***********" -Type String -force
New-ItemProperty -Name DefaultPassword -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Value "************" -Type String -force
New-ItemProperty -Name DefaultDomainName -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Value "***********" -Type String -force
Write-host 'Registry settings created!' -f Green

exit 0
