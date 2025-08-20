$Server = ""
Invoke-Command -ComputerName $Server -ScriptBlock {
    Start-AdSyncSyncCycle -Policytype Delta
    #Get-ADSyncScheduler
    }
