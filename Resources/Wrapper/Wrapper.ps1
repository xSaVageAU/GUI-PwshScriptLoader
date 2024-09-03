param (
    [string]$scriptPath
)

# Start the script process in a new PowerShell window
$psProcess = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -PassThru

# Wait for the process to start
Start-Sleep -Seconds 1

# Use Windows API to resize the window
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class WinAPI {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        public static readonly IntPtr HWND_TOP = IntPtr.Zero;
        public const uint SWP_NOSIZE = 0x0001;
        public const uint SWP_NOMOVE = 0x0002;
        public const uint SWP_NOZORDER = 0x0004;
        public const uint WM_CLOSE = 0x0010;

        public static void SetWindowSize(string windowTitle, int width, int height) {
            IntPtr hWnd = FindWindow(null, windowTitle);
            if (hWnd != IntPtr.Zero) {
                SetWindowPos(hWnd, HWND_TOP, 0, 0, width, height, SWP_NOMOVE | SWP_NOZORDER);
            }
        }

        public static void CloseWindow(string windowTitle) {
            IntPtr hWnd = FindWindow(null, windowTitle);
            if (hWnd != IntPtr.Zero) {
                PostMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
            }
        }
    }
"@

# Resize the window
$windowTitle = "Windows PowerShell"  # Adjust if necessary
[WinAPI]::SetWindowSize($windowTitle, 800, 400)

# Wait for the script to finish
$psProcess.WaitForExit()

# Show a message box
#Add-Type -AssemblyName System.Windows.Forms
#[System.Windows.Forms.MessageBox]::Show("Script has finished running.", "Script Finished", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Close the PowerShell window
[WinAPI]::CloseWindow($windowTitle)