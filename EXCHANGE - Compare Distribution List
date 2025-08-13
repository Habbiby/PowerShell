$DLName = "ALL@onmicrosoft.com"
$OU = ""

#Extract list of users from AD (under $OU)
$ADUsers = Get-ADUser -Filter 'Enabled -eq $True' -SearchBase $OU `
    -Properties proxyAddresses, Description, Title, Department, UserPrincipalName | 
    Where-Object {
        $_.UserPrincipalName -and         #-NE $Null
        $_.Department -and                #-NE $Null
        $_.Name -notlike "*Training*" -and
        $_.Name -notlike "*Test*" -and
        $_.Description -notlike "*Intralot*"
} | Select-Object Name, Description, Title, Department, UserPrincipalName,
    @{N="PrimarySmtpAddress";E={($_.proxyAddresses | Where-Object { $_ -cmatch "^SMTP:" }) -replace "^SMTP:"}} `
    | Sort-Object UserPrincipalName # | Export-Csv "C:\TEMP\ADUsers.csv" -NoTypeInformation



Connect-ExchangeOnline -ShowBanner:$false


#Extract list of users from Distribution List
$DLMembers = Get-DistributionGroupMember -Identity $DLName |
    Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" -and $_.PrimarySmtpAddress } |
    Select-Object Name, PrimarySmtpAddress, Office, RecipientTypeDetails |
    Sort-Object Name # | Export-Csv "C:\TEMP\DistributionListMembers.csv" -NoTypeInformation



#Create a hash set for faster lookup
$DLHash = $DLMembers.PrimarySmtpAddress #| ForEach-Object { $_.ToLower().Trim() }

#Filter AD users not in DL
$MissingMembers = $ADUsers | Where-Object {
    $_.PrimarySmtpAddress -and ($_.PrimarySmtpAddress<#.ToLower().Trim()#> -notin $DLHash)
}

#Display the result
$MissingMembers | Where-Object { $_.Description -notlike "*Mechanical Rock*" } |
Sort-Object Department | Format-Table -AutoSize
