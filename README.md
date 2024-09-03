# GUI-PwshScriptLoader 

***PwshScriptLoader*** is a PowerShell-based graphical user interface (GUI) tool designed to simplify the management and execution of PowerShell scripts.
It provides an intuitive interface for browsing and running scripts.

The GUI script generates menus based on the folders it can see in the `.\Resources\Scripts` directory. Any .ps1 files in those folders will be displayed in its respective menu.

![image](https://github.com/user-attachments/assets/b249b2ba-c069-47d0-8784-9f8b4f7b70f2)



# Features
* ***User-Friendly Interface:*** A clean and responsive GUI built with Windows Forms, allowing users to interact with their scripts effortlessly.
  
* ***Script Management:*** Easily load and view PowerShell scripts from designated folders.

* ***Notifications:*** Includes a checkbox to toggle on or off notifications when scripts are finished running.
  
* ***Real-Time Output:*** View script execution results and errors in a dedicated output area within the GUI.
# Requirements
* **Windows with PowerShell**

# Usage
Add folders with your scripts into the `.\Resources\Scripts` directory.

Run PwshScriptLoader.bat to launch the GUI Script Loader.

Select the script you wish to run, and press the `RUN` button. It will open the script in a new window. If you checked the `Notifications` checkbox you will be notified when the script window closes.

# ToDo
* Add a way to store and read descriptions for scripts.

* Make the GUI more visually appealing.

# Contributions
Contributions are welcome
