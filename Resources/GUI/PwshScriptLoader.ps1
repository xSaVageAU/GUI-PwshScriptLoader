Add-Type -AssemblyName System.Windows.Forms

# Function to read descriptions from config file
function Get-Descriptions {
    param (
        [string]$configFilePath
    )
    
    $descriptions = @{
        'Folders' = @{}
        'Scripts' = @{}
    }

    if (Test-Path $configFilePath) {
        Get-Content $configFilePath | ForEach-Object {
            $line = $_.Trim()
            if ($line -match '^\[(Folder|Script)\](.+)=(.+)$') {
                $type = $matches[1]
                $name = $matches[2].Trim()
                $description = $matches[3].Trim()
                
                if ($type -eq 'Folder') {
                    $descriptions['Folders'][$name] = $description
                } elseif ($type -eq 'Script') {
                    $descriptions['Scripts'][$name] = $description
                }
            }
        }
    }
    return $descriptions
}

# Function to create folder list in the ListView
function Populate-FolderListView {
    param (
        [System.Windows.Forms.ListView]$folderListView,
        [string]$directory,
        [hashtable]$descriptions
    )

    # Clear existing items
    $folderListView.Items.Clear()

    # List all directories
    Get-ChildItem -Path $directory -Directory | ForEach-Object {
        $folderName = $_.Name
        $description = $descriptions['Folders'][$folderName]
        if (-not $description) {
            $description = "Folder containing scripts"
        }
        $item = $folderListView.Items.Add($folderName)
        $item.Tag = $_.FullName
        $item.SubItems.Add($description)
    }
}

# Function to populate script list in the ListView
function Populate-ScriptListView {
    param (
        [System.Windows.Forms.ListView]$scriptListView,
        [string]$directory,
        [hashtable]$descriptions
    )

    # Clear existing items
    $scriptListView.Items.Clear()

    # List all scripts in the directory
    Get-ChildItem -Path $directory -Filter *.ps1 | ForEach-Object {
        $scriptName = $_.Name
        $description = $descriptions['Scripts'][$scriptName]
        if (-not $description) {
            $description = "Description for $scriptName"
        }
        $item = $scriptListView.Items.Add($scriptName)
        $item.Tag = $_.FullName
        $item.SubItems.Add($description)
    }
}

# Function to save descriptions to config file
function Save-Descriptions {
    param (
        [string]$configFilePath,
        [hashtable]$descriptions
    )

    $content = @()

    foreach ($folder in $descriptions['Folders'].Keys) {
        $content += "[Folder]$folder=$($descriptions['Folders'][$folder])"
    }

    foreach ($script in $descriptions['Scripts'].Keys) {
        $content += "[Script]$script=$($descriptions['Scripts'][$script])"
    }

    Set-Content -Path $configFilePath -Value $content
}

function Show-EditDescriptionDialog {
    param (
        [string]$currentDescription,
        [string]$itemName,
        [string]$itemType,
        [hashtable]$descriptions
    )

    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = "Edit Description"
    $dialog.Width = 300
    $dialog.Height = 100
    $dialog.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    $dialog.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $dialog.MaximizeBox = $false
    $dialog.MinimizeBox = $false

    $descriptionTextBox = New-Object System.Windows.Forms.TextBox
    $descriptionTextBox.Text = $currentDescription
    $descriptionTextBox.Multiline = $true
    $descriptionTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $descriptionTextBox.Margin = [System.Windows.Forms.Padding]::new(10)
    $dialog.Controls.Add($descriptionTextBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $okButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
    $okButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $dialog.Controls.Add($okButton)

    $dialog.AcceptButton = $okButton

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $newDescription = $descriptionTextBox.Text.Trim()

        if ($itemType -eq 'Folder') {
            $descriptions['Folders'][$itemName] = $newDescription
        } elseif ($itemType -eq 'Script') {
            $descriptions['Scripts'][$itemName] = $newDescription
        }

        Save-Descriptions -configFilePath $configFilePath -descriptions $descriptions
    }
}

# Get the directory of the script
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptDirectory = Join-Path $scriptRoot "..\Scripts"

# Path to the config file
$configFilePath = Join-Path $scriptRoot "..\Config\Config.txt"
$descriptions = Get-Descriptions -configFilePath $configFilePath

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell Script Loader"
$form.Width = 1000
$form.Height = 500
$form.AutoScroll = $true

# Create the main vertical SplitContainer (for left and right)
$mainSplitContainer = New-Object System.Windows.Forms.SplitContainer
$mainSplitContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainSplitContainer.Orientation = [System.Windows.Forms.Orientation]::Vertical

# Create a horizontal SplitContainer for folder view (left) and status panel (bottom left)
$leftSplitContainer = New-Object System.Windows.Forms.SplitContainer
$leftSplitContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
$leftSplitContainer.Orientation = [System.Windows.Forms.Orientation]::Horizontal
$leftSplitContainer.SplitterDistance = 250

# Create a ListView for the folder list (replacing buttons)
$folderListView = New-Object System.Windows.Forms.ListView
$folderListView.View = [System.Windows.Forms.View]::Details
$folderListView.FullRowSelect = $true
$folderListView.Columns.Add("Folders", -2)
$folderListView.Columns.Add("Description", 400)
$folderListView.Dock = [System.Windows.Forms.DockStyle]::Fill

# Create a ListView for the script list (move to right side)
$scriptListView = New-Object System.Windows.Forms.ListView
$scriptListView.View = [System.Windows.Forms.View]::Details
$scriptListView.FullRowSelect = $true
$scriptListView.Columns.Add("Scripts", 250)
$scriptListView.Columns.Add("Description", -2)
$scriptListView.Dock = [System.Windows.Forms.DockStyle]::Fill

# Define a new font with the desired size
$font = New-Object System.Drawing.Font("Tahoma", 12)  # Font family "Tahoma" and size 12

# Apply the font to the folder list view and script list view
$folderListView.Font = $font
$scriptListView.Font = $font

# Create a TextBox for the status message (bottom panel in left)
$statusTextBox = New-Object System.Windows.Forms.TextBox
$statusTextBox.Multiline = $true
$statusTextBox.ReadOnly = $true
$statusTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$statusTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill

# Add the folder ListView and status TextBox to the left SplitContainer
$leftSplitContainer.Panel1.Controls.Add($folderListView)  # Top panel for folder list
$leftSplitContainer.Panel2.Controls.Add($statusTextBox)   # Bottom panel for status text

# Create the right panel for the script ListView
$rightPanel = New-Object System.Windows.Forms.Panel
$rightPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$rightPanel.Controls.Add($scriptListView)  # Script list now on the right side

# Add the left and right panels to the main SplitContainer
$mainSplitContainer.Panel1.Controls.Add($leftSplitContainer)  # Left panel
$mainSplitContainer.Panel2.Controls.Add($rightPanel)  # Right panel for scripts

# Create checkboxes and RUN button
$notificationCheckbox = New-Object System.Windows.Forms.CheckBox
$notificationCheckbox.Text = "Show Notification"
$notificationCheckbox.Dock = [System.Windows.Forms.DockStyle]::Left

$runInBackgroundCheckbox = New-Object System.Windows.Forms.CheckBox
$runInBackgroundCheckbox.Text = "Run in Background"
$runInBackgroundCheckbox.Dock = [System.Windows.Forms.DockStyle]::Left

$keepOpenCheckbox = New-Object System.Windows.Forms.CheckBox
$keepOpenCheckbox.Text = "Keep PowerShell Open"
$keepOpenCheckbox.Dock = [System.Windows.Forms.DockStyle]::Left

$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "RUN"
$runButton.Size = New-Object System.Drawing.Size(75, 30)

# Create a panel for the checkboxes and run button
$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$bottomPanel.Height = 60
$bottomPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$bottomPanel.Controls.Add($notificationCheckbox)
$bottomPanel.Controls.Add($runInBackgroundCheckbox)
$bottomPanel.Controls.Add($keepOpenCheckbox)
$bottomPanel.Controls.Add($runButton)

# Add panels and controls to the form
$form.Controls.Add($mainSplitContainer)  # Add mainSplitContainer to fill the form
$form.Controls.Add($bottomPanel)         # Add bottomPanel last, so it contains the checkboxes and button

# Function to reposition the RUN button
function Reposition-RunButton {
    $bottomPanelWidth = $bottomPanel.ClientSize.Width
    $bottomPanelHeight = $bottomPanel.ClientSize.Height
    $runButtonX = [int]($bottomPanelWidth - $runButton.Width - 10)  # X position (10px margin from right)
    $runButtonY = [int](([int]($bottomPanelHeight - $runButton.Height)) / 2)  # Y position (centered vertically)
    $runButton.Location = New-Object System.Drawing.Point($runButtonX, $runButtonY)
}

# Call the reposition function to set the initial position
Reposition-RunButton

# Add event handlers for resizing the form
$form.Add_Resize({ Reposition-RunButton })

# Add event handler to set SplitterDistance to 40% of the form's width
$form.Add_Shown({
    $mainSplitContainer.SplitterDistance = [int]($form.ClientSize.Width * 0.40)

    # Select the first item in the folderListView by default if there are items
    if ($folderListView.Items.Count -gt 0) {
        $folderListView.Items[0].Selected = $true
        $folderListView.Select()
        $folderListView.EnsureVisible(0)
    }
})

# Populate folder ListView and handle folder selection
Populate-FolderListView -folderListView $folderListView -directory $scriptDirectory -descriptions $descriptions

# Create context menu for ListView
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$editDescriptionMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$editDescriptionMenuItem.Text = "Edit Description"
$contextMenu.Items.Add($editDescriptionMenuItem)

# Add context menu to ListViews
$folderListView.ContextMenuStrip = $contextMenu
$scriptListView.ContextMenuStrip = $contextMenu

# Handle context menu click event
$editDescriptionMenuItem.Add_Click({
    $selectedItem = $null
    if ($folderListView.Focused) {
        $selectedItem = $folderListView.SelectedItems | Select-Object -First 1
        if ($null -ne $selectedItem) {
            Show-EditDescriptionDialog -currentDescription $selectedItem.SubItems[1].Text -itemName $selectedItem.Text -itemType 'Folder' -descriptions $descriptions
            Populate-FolderListView -folderListView $folderListView -directory $scriptDirectory -descriptions $descriptions
        }
    } elseif ($scriptListView.Focused) {
        $selectedItem = $scriptListView.SelectedItems | Select-Object -First 1
        if ($null -ne $selectedItem) {
            Show-EditDescriptionDialog -currentDescription $selectedItem.SubItems[1].Text -itemName $selectedItem.Text -itemType 'Script' -descriptions $descriptions
            $selectedFolder = $folderListView.SelectedItems | Select-Object -First 1
            if ($null -ne $selectedFolder) {
                Populate-ScriptListView -scriptListView $scriptListView -directory $selectedFolder.Tag -descriptions $descriptions
            }
        }
    }
})

# Function to check if scripts from the folder are already listed
function AreScriptsListed {
    param (
        [System.Windows.Forms.ListView]$scriptListView,
        [string]$folderPath
    )

    # Get all script names in the selected folder
    $scriptsInFolder = Get-ChildItem -Path $folderPath -Filter *.ps1 | Select-Object -ExpandProperty Name

    # Check if all scripts are listed in the ListView
    $listedScripts = $scriptListView.Items | ForEach-Object { $_.Text }

    return ($scriptsInFolder | Where-Object { $listedScripts -notcontains $_ }).Count -eq 0
}

# Add event handler for folder selection (load scripts into the right ListView)
$folderListView.Add_SelectedIndexChanged({
    $selectedItem = $folderListView.SelectedItems | Select-Object -First 1

    if ($null -ne $selectedItem) {
        $selectedFolderPath = $selectedItem.Tag

        # Check if scripts are already listed
        if (-not (AreScriptsListed -scriptListView $scriptListView -folderPath $selectedFolderPath)) {
            # Clear previous script list
            $scriptListView.Items.Clear()

            # List scripts in the selected folder
            Populate-ScriptListView -scriptListView $scriptListView -directory $selectedFolderPath -descriptions $descriptions
        }
    }
})

# Add click event handler for the RUN button
$runButton.Add_Click({
    # Find the selected script
    $selectedItem = $scriptListView.SelectedItems | Select-Object -First 1

    if ($null -ne $selectedItem) {
        # Extract just the filename from the script path
        $scriptFileName = [System.IO.Path]::GetFileName($selectedItem.Tag)
        $statusTextBox.AppendText("Launching script: $scriptFileName...`r`n")
        
        # Determine which wrapper script to use and prepare arguments
        $wrapperScriptPath = Join-Path $scriptRoot "..\Wrapper\Wrapper.ps1"
        $scriptPath = $selectedItem.Tag

        # Prepare arguments for Start-Process
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$wrapperScriptPath`" -scriptPath `"$scriptPath`""

        if ($notificationCheckbox.Checked) {
            $arguments += " -showNotification"
        }
        if ($runInBackgroundCheckbox.Checked) {
            $arguments += " -runInBackground"
        }
        if ($keepOpenCheckbox.Checked) {
            $arguments += " -keepOpen"
        }

        # Run the wrapper script
        try {
            Start-Process powershell.exe -ArgumentList $arguments -WindowStyle Hidden
            $statusTextBox.AppendText("Executing script: $scriptFileName`r`n")
        } catch {
            $statusTextBox.AppendText("Error executing script: $($_.Exception.Message)`r`n")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a script to run.", "No Script Selected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})

# Event handlers for checkbox interactions
$runInBackgroundCheckbox.Add_CheckedChanged({
    if ($runInBackgroundCheckbox.Checked) {
        $keepOpenCheckbox.Enabled = $false
        $keepOpenCheckbox.Checked = $false
    } else {
        $keepOpenCheckbox.Enabled = $true
    }
})

$keepOpenCheckbox.Add_CheckedChanged({
    if ($keepOpenCheckbox.Checked) {
        $runInBackgroundCheckbox.Enabled = $false
        $runInBackgroundCheckbox.Checked = $false
    } else {
        $runInBackgroundCheckbox.Enabled = $true
    }
})

# Show the form
$form.ShowDialog()
