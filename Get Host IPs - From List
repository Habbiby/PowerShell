$Computers = Get-Content -ErrorAction Stop -Path "C:\TEMP\SCCMList.txt" | Where { $_ }

$results = foreach ($comp in $Computers){
    Write-Host "Processing $comp" -foregroundcolor yellow
    $List = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $comp | where -Property Description -notlike "Cisco*" | Select PSComputerName, @{N="IPAddress";E={$_.ipaddress | select -first 1 }}
    IF ($list -eq $null){
        $Comp
    }
    $List
    }




$results | format-table -AutoSize
