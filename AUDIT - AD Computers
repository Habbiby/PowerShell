$Domain = (Get-ADDomain | Select-Object -ExpandProperty Name)

#Query to retrieve all active AD Computer objects, display with a list of attributes
Get-ADComputer -Filter {Enabled -eq $True} -Properties * | `
    Select-Object DistinguishedName, IPv4Address, DNSHostname, OperatingSystem, OperatingSystemServicePack, OperatingSystemVersion, LastLogonDate, WhenChanged | `
    Export-CSV All_Enabled_Computers_$Domain.csv -NoTypeInformation
