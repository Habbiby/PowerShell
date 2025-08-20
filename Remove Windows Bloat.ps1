#Windows 10 / 11
Get-AppxPackage -AllUsers 'Microsoft.WindowsFeedbackHub' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.MicrosoftSolitaireCollection' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.Office.OneNote' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.XboxApp' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.XboxIdentityProvider' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.XboxSpeechToTextOverlay' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.XboxGamingOverlay' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.Xbox.TCUI' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.YourPhone' | Remove-AppxPackage -AllUsers

#Windows 11
Get-AppxPackage -AllUsers 'MicrosoftTeams' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.GetStarted' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.GamingApp' | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers 'Microsoft.XboxGameOverlay' | Remove-AppxPackage -AllUsers
