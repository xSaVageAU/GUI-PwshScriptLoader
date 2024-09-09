# GUI-PwshScriptLoader 

***PwshScriptLoader*** is a PowerShell-based graphical user interface (GUI) tool designed to simplify the management and execution of PowerShell scripts.
It provides an intuitive interface for browsing and running scripts.

The GUI script creates lists based on the folders and scripts it can see in the `.\Resources\Scripts` directory. Any .ps1 files in those folders will be displayed in its respective list.
# 
![image](https://github.com/user-attachments/assets/f436efa2-3e30-4ce0-8568-0a6bf028b598)


# Features
* ***User-Friendly Interface:*** A clean and responsive GUI built with Windows Forms, allowing users to interact with their scripts effortlessly.
  
* ***Script Management:*** Easily load and view PowerShell scripts from designated folders.

* ***Notifications:*** Includes a checkbox to toggle on or off notifications when scripts are finished running.
  
* ***Error Output:*** View script execution results and errors in a dedicated output area within the GUI.
# Requirements
* **Windows with PowerShell**

# Usage
Add folders with your scripts into the `.\Resources\Scripts` directory.

Run `PwshScriptLoader.bat` to launch the GUI Script Loader.

Select the folder and script you wish to run, then press the `RUN` button to execute it. By default it will open the script in a new window. If you checked the `Notifications` checkbox you will be notified when the script wrapper closes.

# ToDo
* Make the GUI more visually appealing.

* Add search script function.

* Include more options and parameters for scripts.

# Contributions
Contributions are welcome
