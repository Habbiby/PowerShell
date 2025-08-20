# Set the search string
$SearchString = "Windows Install"

# init variables
$matchlist = @()
 
# Get the domain name
$DomainName = $env:USERDNSDOMAIN
 
# this line is not needed for newer DCs
#Import-Module grouppolicy   
# collect all GPOs
$GPOs = Get-GPO -All -Domain $DomainName

# Hunt through each GPO XML for the search string
foreach ($gpo in $GPOs) {
    $GPOReport = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    if ($GPOReport -match $SearchString) {
        $matchlist += [string]$gpo.DisplayName
        # this line is just to indicate progress - delete if not needed
        write-host "Match:" $gpo.DisplayName -foregroundcolor "Green"
    }
    else {
        # this line is just to indicate progress - delete if not needed
        Write-Host "No match:" $gpo.DisplayName
    }
}


# output results (likely you want to keep this line)
write-host String "'$SearchString'" found in: -foregroundcolor "Green"
#write-host $matchlist -separator "`n" -foregroundcolor "Green"
$matchlist | sort-object
