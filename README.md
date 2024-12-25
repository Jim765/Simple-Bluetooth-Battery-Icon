This is my first scrip being published on GitHub.

I created this out of a simple desire to not have to open the Logitech software 
to see the battery percentage. 

This is a powershell script and will require you to modify a line for it to work for you.
line 82 	$devicename = "MX Master 3S M"

MX Master 3S M is the FriendlyName of my mouse. You will need to replace this with the
name of your device

To see what the name of your device is, open a PowerShell window and run the command
get-pnpdevice -class Bluetooth

Find your device's FriendlyName in the list and copy that into the quotation marks on line 82

You should be good to run the script at that point.
This script was created with the help of the GitHub Copilot AI
