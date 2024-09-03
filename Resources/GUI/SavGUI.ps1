# Init PowerShell GUI
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$LocalPrinterForm = New-Object System.Windows.Forms.Form

# Define the size, title, and background color
$LocalPrinterForm.ClientSize = '500,400'
$LocalPrinterForm.Text = "SavGUI - Script Loader"
$LocalPrinterForm.BackColor = "#ffffff"

# Create a menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip

# Create "Patches" menu item
$patchesMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$patchesMenuItem.Text = "Patches"

# Create "Themes" menu item
$themesMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$themesMenuItem.Text = "Themes"

# Function to add scripts to panel
function Add-ScriptsToPanel {
    param (
        [string]$folderPath,
        [System.Windows.Forms.Panel]$panel
    )

    # Clear existing controls
    $panel.Controls.Clear()

    # Get all .ps1 files in the folder
    $scripts = Get-ChildItem -Path $folderPath -Filter *.ps1

    $yPos = 10
    foreach ($script in $scripts) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $script.Name
        $label.Tag = $script.FullName
        $label.Location = New-Object System.Drawing.Point(10, $yPos)
        $label.AutoSize = $true
        $label.Padding = New-Object System.Windows.Forms.Padding(5)
        $label.BackColor = "#f0f0f0"
        $label.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $label.Cursor = [System.Windows.Forms.Cursors]::Hand

        # Add hover effect
        $label.Add_MouseEnter({
            param ($sender, $e)
            $sender.BackColor = "#e0e0e0"
        })
        $label.Add_MouseLeave({
            param ($sender, $e)
            $sender.BackColor = "#f0f0f0"
        })

        # Add click event to run the script with confirmation
        $label.Add_Click({
            param ($sender, $e)
            $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to run this script?", "Confirm Execution", [System.Windows.Forms.MessageBoxButtons]::YesNo)
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                $outputBox.Text = "Running script: $($sender.Tag)"
                try {
                    & $sender.Tag | Out-String | % { $outputBox.AppendText($_) }
                    $outputBox.AppendText("Script executed successfully.`n")
                } catch {
                    $outputBox.AppendText("Error: $_`n")
                }
            }
        })

        $panel.Controls.Add($label)
        $yPos += $label.Height + 10
    }
}

# Function to highlight selected menu
function Highlight-SelectedMenu {
    param (
        [System.Windows.Forms.ToolStripMenuItem]$selectedMenuItem
    )

    # Reset all menu items' back color
    foreach ($item in $menuStrip.Items) {
        $item.BackColor = [System.Drawing.Color]::Empty
    }

    # Highlight the selected menu item
    $selectedMenuItem.BackColor = "#d0d0d0"
}

# Create a panel to display scripts
$scriptPanel = New-Object System.Windows.Forms.Panel
$scriptPanel.Location = New-Object System.Drawing.Point(0, 60)
$scriptPanel.Size = New-Object System.Drawing.Size(500, 240)
$scriptPanel.Anchor = 'Top, Left, Right'
$LocalPrinterForm.Controls.Add($scriptPanel)

# Add a text box for output display
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(0, 300)
$outputBox.Size = New-Object System.Drawing.Size(500, 100)
$outputBox.Multiline = $true
$outputBox.ScrollBars = 'Vertical'
$outputBox.ReadOnly = $true
$outputBox.BackColor = "#f0f0f0"
$outputBox.Anchor = 'Bottom, Left, Right'
$LocalPrinterForm.Controls.Add($outputBox)

# Add click events to menu items
$patchesMenuItem.Add_Click({
    Add-ScriptsToPanel -folderPath "C:\Users\SaVage\Desktop\SavGUI-pwsh\Resources\Scripts\Patches" -panel $scriptPanel
    Highlight-SelectedMenu -selectedMenuItem $patchesMenuItem
})

$themesMenuItem.Add_Click({
    Add-ScriptsToPanel -folderPath "C:\Users\SaVage\Desktop\SavGUI-pwsh\Resources\Scripts\Themes" -panel $scriptPanel
    Highlight-SelectedMenu -selectedMenuItem $themesMenuItem
})

# Add menu items to the menu strip
$menuStrip.Items.Add($patchesMenuItem)
$menuStrip.Items.Add($themesMenuItem)

# Add the menu strip to the form
$LocalPrinterForm.MainMenuStrip = $menuStrip
$LocalPrinterForm.Controls.Add($menuStrip)

# Display the form
[void]$LocalPrinterForm.ShowDialog()