$Comp = ""
Invoke-Command -ComputerName $comp -scriptblock {Get-NetConnectionProfile | Select-Object *}
Invoke-Command -ComputerName $comp -scriptblock {cmd.exe /c ipconfig /all}
Invoke-Command -ComputerName $comp -scriptblock {cmd.exe /c netsh lan show profile}

#Tests for metered connection - True / False
Invoke-Command -ComputerName $comp -scriptblock {[void][Windows.Networking.Connectivity.NetworkInformation, Windows, ContentType = WindowsRuntime]
$cost = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile().GetConnectionCost()
$cost.ApproachingDataLimit -or $cost.OverDataLimit -or $cost.Roaming -or $cost.BackgroundDataUsageRestricted -or ($cost.NetworkCostType -ne "Unrestricted")}


<#
Invoke-Command -ComputerName $comp -scriptblock {Get-ExecutionPolicy -Scope CurrentUser}
Invoke-Command -ComputerName $comp -scriptblock {Get-ExecutionPolicy -Scope LocalMachine}
Invoke-Command -ComputerName $comp -scriptblock {Get-ExecutionPolicy -Scope MachinePolicy}
Invoke-Command -ComputerName $comp -scriptblock {Get-ExecutionPolicy -Scope UserPolicy}
#>
