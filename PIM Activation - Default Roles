<#  =====================================================================================
    DESCRIPTION
        Allows for the activiation of PIM roles that are assigned to the user running the script
        Multiple roles are able to be selected at once, but the justification and duration will be the same for each

    NOTES
        Does not work for activiating groups, only specific roles (they have it easy already!)

    FUNCTIONS
        1. Connects to Microsoft Graph with the required permissions
            1.1 Gets information about the user that authenticated with it
            1.2 Prompts the user to login with MFA and saves the token
            1.3 Logs into Microsoft Graph again using MFA

        2. Pulls eligible roles in PIM for current user (not directly assigned)
            2.1 Popup for user to select PIM roles to activate
            2.2 Confirms selected roles aren't already activated, otherwise the script exits
            2.3 Requires additional confirmation if Global Administrator is selected

        3. Variables set by user via prompts (justification and duration of activiation)

        4. Sets parameters for the PIM activation requested based on previous entries and information
            4.1 Activates the selected roles

        5. Goes through each selected role to confirm if it was activated or not

        6. Outputs a list of currently activated roles for the user, sorted by most recently activated

    =====================================================================================
    PREREQUISITES
        1. First time running requires 'Application Administrator' to be activated, due to the required scopes of MgGraph

#========================================================================================#>
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
Write-Host -ForegroundColor Yellow "(1/10) Welcome! Initializing..."
Import-Module -Name MSAL.PS -Force

Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All", "PrivilegedAccess.Read.AzureADGroup", "RoleAssignmentSchedule.ReadWrite.Directory", "RoleManagement.ReadWrite.Directory" -NoWelcome

#Get user information that authentication with Microsoft Graph
$Context = Get-MgContext                             #$Context.Account for UPN
$CurrentUser = Get-MgUser -UserId $Context.Account   #Additionally gets the current users 'Id' object

Write-Host -ForegroundColor Yellow "(2/10) Prompting for credentials and MFA..."
$MSALToken = Get-MSALToken <#-Scopes @(https://graph.microsoft.com/.default)#> -ClientId $Context.ClientId -RedirectUri http://localhost -Authority "https://login.microsoftonline.com/$($Context.TenantId)" `
-Interactive -ExtraQueryParameters @{claims='{"access_token" : {"amr": { "values": ["mfa"] }}}'} -LoginHint $Context.Account

Connect-MgGraph -AccessToken (ConvertTo-SecureString -String $($MSALToken.AccessToken) -AsPlainText -Force) -NoWelcome

#=======================================THE SCRIPT=======================================#

#Pulls eligible roles in PIM for current user (not directly assigned)
#To get a list of all available roles run other script until step 3, then:
#$Results | Sort-Object DisplayName

Write-Host -ForegroundColor Yellow "(3/10) Setting default selected roles..."
$DefaultRoles = @()
$DefaultRoles += [PSCustomObject]@{
    DisplayName = 'Intune Administrator'
    Description = 'Can manage all aspects of the Intune product.'
    Id          = '3a2c62db-5318-420d-8d74-23affee5d9d5'
    IsBuiltIn   = 'True'
    IsEnabled   = 'True'
    }
$DefaultRoles += [PSCustomObject]@{
    DisplayName = 'Application Administrator'
    Description = 'Can create and manage all aspects of app registrations and enterprise apps.'
    Id          = '9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3'
    IsBuiltIn   = 'True'
    IsEnabled   = 'True'
    }
$DefaultRoles += [PSCustomObject]@{
    DisplayName = 'Exchange Administrator'
    Description = 'Can manage all aspects of the Exchange product.'
    Id          = '29232cdf-9323-42fd-ade2-1d097af3e4de'
    IsBuiltIn   = 'True'
    IsEnabled   = 'True'
    }
$DefaultRoles += [PSCustomObject]@{
    DisplayName = 'Global Reader'
    Description = 'Can read everything that a Global Administrator can, but not update anything.'
    Id          = 'f2ef992c-3afb-46b9-b7cf-a126ee74c451'
    IsBuiltIn   = 'True'
    IsEnabled   = 'True'
}
$DefaultRoles += [PSCustomObject]@{
    DisplayName = 'Security Administrator'
    Description = 'Can read security information and reports, and manage configuration in Microsoft Entra ID and Office 365.'
    Id          = '194ae4cb-b126-40b2-bd5b-6091b380977d'
    IsBuiltIn   = 'True'
    IsEnabled   = 'True'
}

#Keep variable consistent between scripts
$SelectedRoles = $DefaultRoles

##################################################

#Confirms selected roles aren't already activated
Write-Host -ForegroundColor Yellow "(4/10) Comparing already activated roles for $($Context.Account)"
$Roles = Get-MgRoleManagementDirectoryRoleAssignmentScheduleInstance  -Filter "principalId eq '$($CurrentUser.Id)'" | `
            Select-Object AssignmentType, MemberType, RoleDefinitionId, StartDateTime, EndDateTime
$Test = ForEach($Role in $Roles){
    IF($Role.RoleDefinitionId -in $SelectedRoles.Id){
        Get-MgRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $Role.RoleDefinitionId | `
        Select-Object DisplayName, Description, `
            @{n="StartDateTime";e={$Role.StartDateTime.AddHours(8)}}, `
            @{n="EndDateTime";e={$Role.EndDateTime.AddHours(8)}}, `
            @{n="AssignmentType";e={$Role.AssignmentType}}, `
            @{n="MemberType";e={$Role.MemberType}}, ID
    }
}

IF($Test){
    Write-Host -ForegroundColor Red "Failed. These roles already activated for" $Context.Account
    $Test | format-table -AutoSize
    Write-Host -ForegroundColor Red "Please select roles not already activated."
    Read-Host -Prompt "Press Enter to exit"
    Break
}

##Requires additional confirmation if Global Administrator is selected
IF($SelectedRoles.DisplayName -eq "Global Administrator"){
    Write-Host "(4.1/10) WARNING! Global Administrator has been selected." -ForegroundColor Red
    Write-Host "Confirm you you would like to continue enabling Global Administrator." -ForegroundColor Yellow
    $GAConfirmation = $(Write-Host -ForeGroundColor Yellow "Yes / No: " -NoNewLine ) + $(Read-Host) 
    IF($GAConfirmation -eq "Yes"){
        Write-Host -ForegroundColor Green "Continuing..."
        }
    IF($GAConfirmation -eq "No"){
        Write-Host -ForegroundColor Red "Exiting..." 
        Read-Host -Prompt "Press Enter to exit"
        Break
        }
    
    ELSEIF(($GAConfirmation -ne "Yes") -and ($GAConfirmation -ne "No")){
        Write-Host -ForegroundColor Red "Unknown input, exiting..." 
        Read-Host -Prompt "Press Enter to exit"
        Break
    }
}

###################################################

#Variables set by user: Justification and duration of activiation
#Keeps looping until a valid input is received
Write-Host -ForegroundColor Yellow "(5/10) Selected role(s):"
$SelectedRoles | Select-Object DisplayName, Description | Out-Host

Write-Host "One, two skip a few"
$Justification = "BAU"
$Duration = "8"
Write-Host -ForegroundColor Yellow "(6/10) Justification: $($Justification)"
Write-Host -ForegroundColor Yellow "(7/10) Duration: $($Duration)"

###################################################
$Counter = 0
Write-Host -ForegroundColor Yellow "(8/10) Activating role(s)..."
#Sets parameters for the PIM activation requested, based on previous entries and information
ForEach ($SelectedRole in $SelectedRoles){
  $params = @{
  "PrincipalId" = $CurrentUser.Id #User Id
  "RoleDefinitionId" = $SelectedRole.Id #PIM Role Id
  "Justification" = $Justification
  "DirectoryScopeId" = "/"
  "Action" = "SelfActivate"
  "ScheduleInfo" = @{
    "StartDateTime" = Get-Date
    "Expiration" = @{
       "Type" = "AfterDuration"
       "Duration" = "PT$([int]$Duration)H"
       }
     }
    }

#PIM activation request
$Counter++
Write-Host -ForegroundColor Yellow "(8.$($Counter)/10) Activating role: '$($SelectedRole.DisplayName)'"
New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params |
  Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionID, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime, TargetScheduleID | Out-Null -ErrorAction SilentlyContinue

#Delay before running it again, can only have one pending request at a time
Start-Sleep 3
}

###################################################

#Get active roles for user with more human readable relevant info (again, as new role should now be assigned)
$Roles = Get-MgRoleManagementDirectoryRoleAssignmentScheduleInstance  -Filter "principalId eq '$($CurrentUser.Id)'" | `
            Select-Object AssignmentType, MemberType, RoleDefinitionId, StartDateTime, EndDateTime
$UserActivations = ForEach($Role in $Roles){
    Get-MgRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $Role.RoleDefinitionId | `
        Select-Object DisplayName, Description, `
            @{n="StartDateTime";e={$Role.StartDateTime.AddHours(8)}}, `
            @{n="EndDateTime";e={$Role.EndDateTime.AddHours(8)}}, `
            #@{n="AssignmentType";e={$Role.AssignmentType}}, `
            @{n="MemberType";e={$Role.MemberType}}, ID
}
##################################################

#Goes through each selected role to confirm if it was successfully enabled or not
$Counter2 = 0
ForEach($SelectedRole in $SelectedRoles){
$Counter2++
IF($SelectedRole.Id -in $UserActivations.Id){
    Write-Host -ForegroundColor Green "(9.$($Counter2)/10) Success! Activated the '$($SelectedRole.DisplayName)' role for '$($Context.Account)'"
    }
IF($SelectedRole.Id -notin $UserActivations.Id){
    Write-Host -ForegroundColor Red "(9.$($Counter2)/10) Failure! Did not activate the '$($SelectedRole.DisplayName)' role for '$($Context.Account)'"
    }

}

#Lists all activated roles for the user
Write-Host -ForegroundColor Green "(10/10) Currently activated roles:"
$UserActivations | Sort-Object StartDateTime  -Descending | ft -AutoSize

###################################################

Read-Host -Prompt "Press Enter to exit"
