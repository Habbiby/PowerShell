<#  =====================================================================================
    DESCRIPTION
        Allows domain administrators to quickly and easily add or remove user(s) from the standard groups in AAD or AD for application or SSO access
        Two lists will popup, one to select users (from $OU), and one to groups, which are predefined in a .csv (and can be added to)
        If there is a respective ADGroup and AADGroup, the user(s) will be added to both
        
    NOTES
        Can only put spaces in the popup lists when it's not the end of the string (apparently works outside of PS ISE though?)

    FUNCTIONS
        1. Connects to AzureAD

        2. User input for if they want to add or remove the users from the groups
            2.1 Add or remove the user(s) in the chosen groups based on the user input
        
        3. A pop-up list is given to users, which is queried from AD for a list of users to select from
                
        4. A pop-up list is given to users, which is imported from a .csv on LW-PR-FS-01 to select which groups / applications the users are to be added to
        
        5. Outputs a list of changes based on the values chosen in the above steps 
            4.1 Asks for confirmation to continue in the script, otherwise it will exit
            
        6. Runs through each user, in each group to remove or add them, outputting the step as it runs

        7. Checks to see if each user is in each group and outputs the result (In Group / Not in group)

    =====================================================================================
    PREREQUISITES
        1. Open Run, enter appwiz.cpl
            1.1 Click "Turn Windows features on or off" (Requires admin privs)
            1.2 Enable "Active Directory Lightweight Directory Services"
            
        2. Enter credentials when prompted 
            2.1 Will only do it the first time the PowerShell session is launched

        3. Access to add or remove groups in AD and AAD

        4. AzureAD & ActiveDirectory PowerShell modules

#===================================VARIABLES TO SET=====================================#>

$OU = ""
$FilePath = "C:\TEMP\Add Users Source File.csv"

#========================================================================================#


#Save credentials to PowerShell session so it's not required to be entered every time - Saved as a secure string
IF ($Credentials -isnot [PSCredential]) {
    $Credentials = Get-Credential
}

Import-Module -Name AzureAD
Connect-AzureAD -Credential $Credentials | Out-Null


#=====================================User Prompts=======================================#

Write-Host 'Please type "Remove" or "Add"' -ForegroundColor Yellow
$Option = Read-Host "Would you like to remove or add user(s) to the AD / AAD group(s)?"

IF (($Option -ne "Remove") -and ($Option -ne "Add")){
    Write-Host "Incorrect input, exiting..." -ForegroundColor Yellow
    return
}
''

#----------------------------------Applications & Users----------------------------------#

$ADUsers = Get-ADUser -Filter * -SearchBase $OU | Select-object Name,UserPrincipalName, DistinguishedName | Sort-Object -Property Name | Out-Gridview -Title "Select your user(s) from AD, spaces don't work if it's at the end of the search string, use quotation marks for a better search" -PassThru
Write-Host "Select users in the pop-up prompt..." -foregroundcolor yellow

$csv = Import-Csv $FilePath

$Apps = $csv | Out-GridView -title "App(s) selection, spaces don't work if it's at the end of the search string, use quotation marks for a better search" -PassThru
Write-Host "Select applications in the pop-up prompt..." -foregroundcolor yellow

#===================================Confirming Actions===================================#

''
Write-Host "Please confirm the below changes before continuting:" -foregroundcolor yellow
IF($Option -eq "Add"){
    $Language = "to"
}
IF($Option -eq "Remove"){
    $Language = "from"
}

(Get-Culture).Option
ForEach($User in $ADUsers){
    ForEach($App in $Apps){
        Write-Host (Get-Culture).TextInfo.ToTitleCase($Option) $User.Name $Language $App.ADGroup $App.AzureGroup

    }
}
''
$Confirmation = Read-Host "Continue? Yes / No"
IF($Confirmation -ne "Yes"){
    Write-Host "Exiting...."
    return
}


#=======================================THE SCRIPT=======================================#

ForEach($User in $ADUsers){
    $AADUser = Get-AzureADUser -All $True | Where-Object UserPrincipalName -eq $User.UserPrincipalName #| Out-Null
    ForEach($App in $Apps){
        $Title = (Get-Culture).TextInfo.ToTitleCase($Option) + " " + $User.Name + " " + $Language + " " + $App.Name
        $UserObjectId = $AADUser.ObjectId

#======================================Adding Users======================================#
        IF ($Option -eq "Add"){

            IF ($App.Environment -eq "Azure"){
                Write-Host "Adding" $User.Name "to AAD group" $App.AzureGroup -ForegroundColor Yellow
                $AADTest = Get-AzureADGroupMember -ObjectID $App.GroupObjectId | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName

                IF ($AADTest -eq $Null){
                    Add-AzureADGroupMember -ObjectID $App.GroupObjectId -RefObjectId $UserObjectId
                }
            }
            IF ($App.Environment -eq "AD"){
                Write-Host "Adding" $User.Name "to AD group" $App.ADGroup -ForegroundColor Yellow       
                Add-ADGroupMember -Identity $App.ADGroup -Members $User.DistinguishedName -Confirm:$false
            }
            IF ($App.Environment -eq "Azure + AD"){
                Write-Host "Adding" $User.Name "to AAD group" $App.AzureGroup -ForegroundColor Yellow
                Write-Host "Adding" $User.Name "to AD group" $App.ADGroup -ForegroundColor Yellow
                Add-ADGroupMember -Identity $App.ADGroup -Members $User.DistinguishedName -Confirm:$false
                $AADTest2 = Get-AzureADGroupMember -ObjectID $App.GroupObjectId | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName

                    IF ($AADTest2 -eq $Null){
                    Add-AzureADGroupMember -ObjectId $App.GroupObjectId -RefObjectId $UserObjectId
                    }
        }
        }
#=====================================Removing Users=====================================#
        IF ($Option -eq "Remove"){

            IF ($App.Environment -eq "Azure"){
                Write-Host "Removing" $User.Name "from AAD group" $App.AzureGroup -ForegroundColor Yellow
                $AADTest = Get-AzureADGroupMember -ObjectID $App.GroupObjectId | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName

                IF ($AADTest -ne $Null){
                    Remove-AzureADGroupMember -ObjectID $App.GroupObjectId -MemberId $UserObjectId
                }
            }
            IF ($App.Environment -eq "AD"){
                Write-Host "Removing" $User.Name "from AD group" $App.ADGroup -ForegroundColor Yellow       
                Remove-ADGroupMember -Identity $App.ADGroup -Members $User.DistinguishedName -Confirm:$false
            }

            IF ($App.Environment -eq "Azure + AD"){
                Write-Host "Removing" $User.Name "from AAD group" $App.AzureGroup -ForegroundColor Yellow
                Write-Host "Removing" $User.Name "from AD group" $App.ADGroup -ForegroundColor Yellow
                Remove-ADGroupMember -Identity $App.ADGroup -Members $User.DistinguishedName -Confirm:$false
                $AADTest2 = Get-AzureADGroupMember -ObjectID $App.GroupObjectId | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName

                    IF ($AADTest2 -ne $Null){
                    Remove-AzureADGroupMember -ObjectId $App.GroupObjectId -MemberId  $UserObjectId
                    }
            }
        }
   } #ForEach App
} #ForEach User

#======================================Final Checks======================================#

''
Write-Host "Running checks..." -foregroundcolor yellow

ForEach($App in $Apps){
    $CheckResults = ForEach($User in $ADUsers){
        
        $App.AADResult = $Null
        $App.ADResult = $Null

        IF (-not [string]::IsNullOrWhiteSpace($App.AzureGroup)){
            $App.AADResult = Get-AzureADGroupMember -ObjectID $App.GroupObjectId | Where-Object -Property UserPrincipalName -eq $User.UserPrincipalName -ErrorAction SilentlyContinue
            start-sleep -Seconds 2
            IF ($App.AADResult -ne $Null){
                $App.AADResult = "In Group"
            }
            IF ($App.AADResult -eq $Null){
                $App.AADResult = "Not in Group"
            }
        }

        IF (-not [string]::IsNullOrWhiteSpace($App.ADGroup)){
            $App.ADResult = Get-ADGroupMember -Identity $App.ADGroup | Where-Object -Property Name -eq $User.Name -ErrorAction SilentlyContinue
            start-sleep -Seconds 2
            IF ($App.ADResult -ne $Null){
                $App.ADResult = "In Group"
            }
            IF ($App.ADResult -eq $Null){
                $App.ADResult = "Not in Group"
            }
        }

      $Apps | select-object @{Name="UserPrincipalName";Expression={$User.UserPrincipalName}}, AppName, Environment, ADGroup, AzureGroup, ADResult, AADResult

   } #ForEach User
} #ForEach App
$CheckResults | Sort-Object -Property AppName -Descending | Format-Table
