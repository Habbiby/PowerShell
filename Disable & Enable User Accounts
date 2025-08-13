<#  =====================================================================================
    DESCRIPTION
        Disables or enable the user in AAD, AD, Office 365 and hides/shows them from the Global Address list in Outlook
        This script only supports disabling or enabling one user at a time

    NOTES
        Disabling or enabling the user in AAD also does it in Office 365, hence why there is no O365 section

    FUNCTIONS
        1. Connects to Exchange Online and Azure AD with the given credentials
        
        2. Runs a pre-check on the specified account, outputting if the user is disabled or enabled already

        3. Prompts the user if they want to enable or disable the user account

        4. Disables or enables the user based on the given input
            3.1 Then runs a check again to confirm if the user is enabled or disabled

    =====================================================================================
    PREREQUISITES
        1. Open Run, enter appwiz.cpl
            1.1 Click "Turn Windows features on or off" (Requires admin privs)
            1.2 Enable "Active Directory Lightweight Directory Services"
            
        2. Enter credentials when prompted 
            2.1 Will only do it the first time the PowerShell session is launched

        3. This PowerShell script is required to be ran as admin for the Active Directory changes

#===================================VARIABLES TO SET=====================================#>

$OU = ""

#----------------------------------------------------------------------------------------#

$ADUsers = $Null

$ADUsers1 = Get-ADUser -Filter * -SearchBase $OU
$ADUsers2 = Get-ADUser -Filter * -SearchBase $OU

Write-Host "Select users in the pop-up prompt..." -foregroundcolor yellow

$ADUsers = $ADUsers1 + $ADUsers2 | Select-object Name,UserPrincipalName, DistinguishedName, SamAccountName | Sort-Object -Property Name | Out-Gridview -Title "Select your user(s) from AD, spaces don't work if it's at the end of the search string, use quotation marks for a better search" -PassThru

#========================================================================================#
#Save credentials to PowerShell session so it's not required to be entered every time - Saved as a secure string
IF ($Credentials -isnot [PSCredential]) {
    $Credentials = Get-Credential
}
#----------------------------------------------------------------------------------------#


#==============================Connecting to Environments================================#

#Install-Module -Name "AzureAD"
Import-Module -Name "AzureAD"
Connect-AzureAD -Credential $Credentials |out-null

Import-Module ActiveDirectory

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -Credential $Credentials -ShowBanner:$false

#----------------------------------------------------------------------------------------#




#=======================================THE SCRIPT=======================================#

ForEach ($User in $ADUsers){

#===================================Pre-Check====================================#

Write-Host -ForegroundColor Yellow "RUNNING PRE-CHECKS..."

#===================================Azure AD=====================================#
$AADCheck = (Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -eq $User.UserPrincipalName}).AccountEnabled
$Token = (Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -eq $User.UserPrincipalName}).ObjectID

IF ($AADCheck -eq $false){
    Write-host $User.UserPrincipalName "already disabled in Azure AD" -ForegroundColor Red
}
Else{
    Write-host $User.UserPrincipalName "not disabled in Azure AD" -ForegroundColor Green
}

#=================================Active Directory===============================#
$ADCheck = Search-ADAccount –AccountDisabled –UsersOnly | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName

IF ($ADCheck -ne $Null){
    Write-host $User.UserPrincipalName "already disabled in AD" -ForegroundColor Red
}
Else{
    Write-host $User.UserPrincipalName "not disabled in AD" -ForegroundColor Green
}

#===================================Exchange===================================#
$DistinguishedName = (Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -like $User.UserPrincipalName}).ExtensionProperty.onPremisesDistinguishedName 
$HideMail = (Get-ADUser -identity $DistinguishedName -Property msExchHideFromAddressLists).msExchHideFromAddressLists

IF ($HideMail -eq $True){
    write-host $User.UserPrincipalName "already hidden from Global Address List (GAL)" -ForegroundColor Red
}
IF ($HideMail -eq $Null){
    write-host $User.UserPrincipalName "not hidden from Global Address List (GAL)" -ForegroundColor Green
}

}


#====================================Prompt====================================#

''
Write-Host 'Type in either "Disable" or "Enable"' -ForegroundColor Yellow
$Able = Read-Host "Would you like to Disable or Enable the user(s)?"
''

IF (($Able -ne "Disable") -and ($Able -ne "Enable")){
    Write-Host "Incorrect input, exiting..." -ForegroundColor Yellow
    return
}

#=================================Disabling User===============================#
ForEach ($User in $ADUsers){

IF ($Able -eq "Disable"){
        Write-Host -ForegroundColor Yellow "DISABLING USER..."

        Revoke-AzureADUserAllRefreshToken -ObjectId $Token                                      #AAD
        Set-AzureADUser -ObjectID $User.UserPrincipalName -AccountEnabled $False                              #AAD

        Disable-ADAccount -Identity $User.SamAccountName                                                   #AD

        Set-ADObject -Identity $DistinguishedName -replace @{msExchHideFromAddressLists=$True}  #Exchange

        Start-Sleep -Seconds 15

        #===================================Azure AD=====================================#
        
        $AADCheck2 = (Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -eq $User.UserPrincipalName}).AccountEnabled
        
        IF ($AADCheck2 -eq $false){
            Write-host $User.UserPrincipalName "disabled in Azure AD" -ForegroundColor Red
        }
        Else{
            Write-host $User.UserPrincipalName "not disabled in Azure AD" -ForegroundColor Green
        }

        #=================================Active Directory===============================#

        $ADCheck2 = Search-ADAccount –AccountDisabled –UsersOnly | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName

        IF ($ADCheck2 -ne $Null){
            Write-host $User.UserPrincipalName "disabled in AD" -ForegroundColor Red
        }
        Else{
            Write-host $User.UserPrincipalName "not disabled in AD" -ForegroundColor Green
        }

        #===================================Exchange===================================#

        $HideMail2 = (Get-ADUser -identity $DistinguishedName -Property msExchHideFromAddressLists).msExchHideFromAddressLists

        IF ($HideMail2 -eq $True){
            write-host $User.UserPrincipalName "hidden from Global Address List (GAL)" -ForegroundColor Red
        }
        IF ($HideMail2 -eq $Null){
            write-host $User.UserPrincipalName "not hidden from Global Address List (GAL)" -ForegroundColor Green
        }
}


#=================================Enabling User===================================#

IF ($Able -eq "Enable"){
        Write-Host -ForegroundColor Yellow "ENABLING USER..."
        
        Set-AzureADUser -ObjectID $User.UserPrincipalName -AccountEnabled $True                              #AAD

        Enable-ADAccount -Identity $User.SamAccountName                                                   #AD

        Set-ADObject -Identity $DistinguishedName -Clear msExchHideFromAddressLists            #Exchange

        Start-Sleep -Seconds 15

        #===================================Azure AD=====================================#

        $AADCheck2 = (Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -eq $User.UserPrincipalName}).AccountEnabled

        IF ($AADCheck2 -eq $false){
            Write-host $User.UserPrincipalName "disabled in Azure AD" -ForegroundColor Red
        }
        Else{
            Write-host $User.UserPrincipalName "not disabled in Azure AD" -ForegroundColor Green
        }

        #=================================Active Directory===============================#

        $ADCheck2 = Search-ADAccount –AccountDisabled –UsersOnly | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName

        IF ($ADCheck2 -ne $Null){
            Write-host $User.UserPrincipalName "disabled in AD" -ForegroundColor Red
        }
        Else{
            Write-host $User.UserPrincipalName "not disabled in AD" -ForegroundColor Green
        }

        #===================================Exchange===================================#

        $HideMail2 = (Get-ADUser -identity $DistinguishedName -Property msExchHideFromAddressLists).msExchHideFromAddressLists

        IF ($HideMail2 -eq $True){
            write-host $User.UserPrincipalName "hidden from Global Address List (GAL)" -ForegroundColor Red
        }
        IF ($HideMail2 -eq $Null){
            write-host $User.UserPrincipalName "not hidden from Global Address List (GAL)" -ForegroundColor Green
        }
}

}
