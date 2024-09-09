# Add the type for showing a message box
Add-Type -AssemblyName System.Windows.Forms

# Define the message
$message = "You can execute scripts!"

# Show the message in a popup
[System.Windows.Forms.MessageBox]::Show($message, "Test Message", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Write the message to the PowerShell host window
Write-Host $message
