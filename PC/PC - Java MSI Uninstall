# Remove: Java - previous versions
$Application = "Java"

#Uncomment lines that are required to be uninstalled
$oldVersions = @(
#"{C88E1536-B969-551C-BD73-956329A6D5B0}"  #v22.0.1
#"{C040F277-8073-5419-8837-0A557896FFD1}"  #v21.0.3
#"{77924AE4-039E-4CA4-87B4-2F32180411F0}"  #v411 (32bit)
#"{77924AE4-039E-4CA4-87B4-2F64180411F0}"  #v411 (64bit)
#"{26A24AE4-039D-4CA4-87B4-2F32180111F0}"  #v111 (32bit)
#"{26A24AE4-039D-4CA4-87B4-2F64180111F0}"  #v111 (64bit)
#"{26A24AE4-039D-4CA4-87B4-2F32180201F0}"
#"{26A24AE4-039D-4CA4-87B4-2F32180251F0}"  #v251 (32bit)
#"{26A24AE4-039D-4CA4-87B4-2F32180261F0}"
#"{26A24AE4-039D-4CA4-87B4-2F32180361F0}"  #v361 (32bit)

#"{26A24AE4-039D-4CA4-87B4-2F64180201F0}"
#"{26A24AE4-039D-4CA4-87B4-2F64180251F0}"  #v251 (64bit)
#"{26A24AE4-039D-4CA4-87B4-2F64180261F0}"
#"{26A24AE4-039D-4CA4-87B4-2F64180271F0}"
#"{26A24AE4-039D-4CA4-87B4-2F64180361F0}"  #v361 (64bit)
#"{77924AE4-039E-4CA4-87B4-2F64180381F0}"  #v381 (64bit)
#"{4A03706F-666A-4037-7777-5F2748764D10}"  #Java Auto Updater
#"{71024AE4-039E-4CA4-87B4-2F32180401F0}"
#"{71024AE4-039E-4CA4-87B4-2F64180401F0}"
)


#$Computers = Get-Content -ErrorAction Stop -Path "C:\Temp\ComputerAssetList.txt" | Where { $_ }
$Computers = ""


ForEach ($Comp in $Computers){

    $Ping = Test-Connection -ComputerName $Comp -count 2 -Quiet
    IF ($Ping -eq $True) {

        ForEach ($oldVersion In $oldVersions) {

            Write-Host "Trying to remove $oldversion on $comp" -ForegroundColor Yellow

            $MSIArguments = @(
                "/x"
                "$oldVersion"
                "/qn"
                'REBOOT="ReallySuppress"'
            )
        
            #Invoke-Command –ComputerName $Comp –ScriptBlock {Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'} | Where-Object -Property DisplayName -like "*$Application*"
            Invoke-Command -AsJob –ComputerName $Comp –ScriptBlock {Start-Process "msiexec.exe" -ArgumentList $Using:MSIArguments -PassThru -Wait -NoNewWindow | out-null}
            Start-Sleep -Seconds 1

        }
    }
        ELSE{
        Write-Host "Couldn't ping $comp" -ForegroundColor Red
        }
}
   
