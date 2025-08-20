# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

# Store the data from NewUsersFinal.csv in the $ADUsers variable
$ADUsers = Import-Csv "C:\Temp\Scripts\NewUsersSent.csv"

# Define UPN
$UPN = ""

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {
    try {
        $UserParams = @{
            SamAccountName        = $User.username
            UserPrincipalName     = "$($User.username)@$UPN"
            Name                  = "$($User.firstname) $($User.lastname)"
            GivenName             = $User.firstname
            Surname               = $User.lastname
            Enabled               = $True
            DisplayName           = "$($User.firstname) $($User.lastname)"
            Path                  = $User.ou
            EmailAddress          = $User.email
            Title                 = $User.jobtitle
            Description           = $User.description
            AccountPassword       = (ConvertTo-secureString $User.password -AsPlainText -Force)
            ChangePasswordAtLogon = $False
        }


        # Check to see if the user already exists in AD
        if (Get-ADUser -Filter "SamAccountName -eq '$($User.username)'") {

            # Give a warning if user exists
            Write-Host "A user with username $($User.username) already exists in Active Directory." -ForegroundColor Yellow
        }
        else {
            # User does not exist then proceed to create the new user account
            # Account will be created in the OU provided by the $User.ou variable read from the CSV file
            New-ADUser @UserParams

            # If user is created, show message.
            Write-Host "The user $($User.username) is created." -ForegroundColor Green
        }
    }
    catch {
        # Handle any errors that occur during account creation
        Write-Host "Failed to create user $($User.username) - $_" -ForegroundColor Red
    }
}
