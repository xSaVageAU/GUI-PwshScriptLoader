Add-Type -AssemblyName System.Windows.Forms

# Function to create buttons based on directory structure
function Create-Buttons {
    param (
        [System.Windows.Forms.Panel]$panel,
        [string]$directory
    )

    # Clear existing buttons
    $panel.Controls.Clear()

    # Calculate button size and spacing
    $buttonWidth = 100
    $buttonHeight = 30
    $xSpacing = 10
    $ySpacing = 10

    # Set initial positions
    $xPos = 10
    $yPos = 10
    $maxWidth = $panel.ClientSize.Width

    Get-ChildItem -Path $directory -Directory | ForEach-Object {
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $_.Name
        $button.Tag = $_.FullName
        $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
        $button.Location = New-Object System.Drawing.Point($xPos, $yPos)
        $button.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
        $button.Add_Click({
            param($sender, $eventArgs)
            $clickedButton = $sender -as [System.Windows.Forms.Button]
            # Clear previous script list
            $scriptListView.Items.Clear()

            # List scripts in the selected directory
            foreach ($script in Get-ChildItem -Path $clickedButton.Tag -Filter *.ps1) {
                # Add an item to the ListView
                $item = $scriptListView.Items.Add($script.Name)
                $item.Tag = $script.FullName
                $item.SubItems.Add("Description for $($script.Name)")
            }
        })
        $panel.Controls.Add($button)

        # Update positions for next button
        $xPos += $buttonWidth + $xSpacing
        if ($xPos + $buttonWidth > $maxWidth) {
            $xPos = 10
            $yPos += $buttonHeight + $ySpacing
        }
    }
}

# Get the directory of the script
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Set the script directory based on the script location
$scriptDirectory = Join-Path $scriptRoot "Resources\Scripts"

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell Script Loader"
$form.Width = 800
$form.Height = 600

# Create a panel to hold the buttons (menu)
$menuPanel = New-Object System.Windows.Forms.Panel
$menuPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$menuPanel.Height = 50
$menuPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D

# Create a ListView for the script list
$scriptListView = New-Object System.Windows.Forms.ListView
$scriptListView.View = [System.Windows.Forms.View]::Details
$scriptListView.FullRowSelect = $true
$scriptListView.Columns.Add("Name", 150)
$scriptListView.Columns.Add("Description", 400)
$scriptListView.Location = New-Object System.Drawing.Point(10, 60)
$scriptListView.Size = New-Object System.Drawing.Size(760, 250)
$scriptListView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom

# Create a panel for the ListView
$scriptPanel = New-Object System.Windows.Forms.Panel
$scriptPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$scriptPanel.Height = 320
$scriptPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$scriptPanel.Controls.Add($scriptListView)

# Create a checkbox to toggle notification
$notificationCheckbox = New-Object System.Windows.Forms.CheckBox
$notificationCheckbox.Text = "Notifications"
$notificationCheckbox.Location = New-Object System.Drawing.Point(10, 520)
$notificationCheckbox.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

# Create a textbox for the status message
$statusTextBox = New-Object System.Windows.Forms.TextBox
$statusTextBox.Multiline = $true
$statusTextBox.ReadOnly = $true
$statusTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$statusTextBox.Location = New-Object System.Drawing.Point(10, 380)  # Adjusted location
$statusTextBox.Size = New-Object System.Drawing.Size(760, 140)  # Adjusted size to cover the panel space
$statusTextBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# Create a RUN button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "RUN"
$runButton.Location = New-Object System.Drawing.Point(700, 520)
$runButton.Size = New-Object System.Drawing.Size(75, 30)
$runButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$runButton.Add_Click({
    # Find the selected script
    $selectedItem = $scriptListView.SelectedItems | Select-Object -First 1

    if ($null -ne $selectedItem) {
        $statusTextBox.AppendText("Launching script: $($selectedItem.Tag) in a new window...`r`n")
        
        # Determine which wrapper script to use
        $wrapperScriptPath = if ($notificationCheckbox.Checked) {
            Join-Path $scriptRoot "Resources\Wrapper\WrapperNotify.ps1"
        } else {
            Join-Path $scriptRoot "Resources\Wrapper\Wrapper.ps1"
        }
        $scriptPath = $selectedItem.Tag

        # Run the wrapper script hidden
        try {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$wrapperScriptPath`" -scriptPath `"$scriptPath`"" -WindowStyle Hidden
            $statusTextBox.AppendText("Executing Script $($scriptPath) .`r`n")
        } catch {
            $statusTextBox.AppendText("Error executing script: $($_.Exception.Message)`r`n")
        }
    } else {
        $statusTextBox.AppendText("No script selected.`r`n")
    }
})
$form.Controls.Add($runButton)

# Add panels and controls to the form
$form.Controls.Add($scriptPanel)   # Add scriptPanel first, so it's below the menuPanel
$form.Controls.Add($notificationCheckbox)  # Add checkbox after the scriptPanel
$form.Controls.Add($statusTextBox)  # Add statusTextBox after the checkbox
$form.Controls.Add($menuPanel)     # Add menuPanel last, so it's at the top

# Generate buttons based on the directory structure
Create-Buttons -panel $menuPanel -directory $scriptDirectory

# Show the form
$form.ShowDialog()