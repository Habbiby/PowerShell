$OU = 
$EnabledUsers = Get-ADUser -Filter 'Enabled -eq "True"' -Properties * -SearchBase $OU | `
    Select-object DisplayName, UserPrincipalName, Title, Department, DistinguishedName 

$SortedUsers = $EnabledUsers | Sort-Object Title -Descending | Sort-Object Department -Descending | Format-Table -AutoSize

$SortedUsers
$SortedUsers | Export-Csv -NoTypeInformation "C:\TEMP\ADUsers.csv"
