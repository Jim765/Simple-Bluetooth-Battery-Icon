# Requires Windows 10 or later
# Requires PowerShell 5.1 or later
# Requires the Bluetooth device to support the Bluetooth Battery Service (BAS)
# Requires the Bluetooth device to be paired with the computer
# Requires the .net framework to be installed

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to get battery level of a specific Bluetooth device
function Get-BluetoothDeviceBatteryLevel {
    param (
        [string]$DeviceFriendlyName
    )

    $device = Get-PnpDevice -FriendlyName "*$DeviceFriendlyName*"

    if ($device) {
        $batteryProperty = Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' |
            Where-Object { $_.Type -ne 'Empty' } |
            Select-Object -ExpandProperty Data

        if ($batteryProperty) {
            return $batteryProperty
        } else {
            Write-Host "No battery level information found for $DeviceFriendlyName."
            return $null
        }
    } else {
        Write-Host "Bluetooth device $DeviceFriendlyName not found."
        return $null
    }
}

# Function to create a battery icon based on the battery level
function Get-BatteryIcon {
    param (
        [int]$BatteryLevel
    )

    $icon = New-Object System.Drawing.Bitmap 16, 16
    $graphics = [System.Drawing.Graphics]::FromImage($icon)
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $batteryColor = [System.Drawing.Color]::Green
    if ($BatteryLevel -lt 20) {
        $batteryColor = [System.Drawing.Color]::Red
    } elseif ($BatteryLevel -lt 50) {
        $batteryColor = [System.Drawing.Color]::Yellow
    }

    $graphics.FillRectangle([System.Drawing.Brushes]::Gray, 0, 0, 16, 16)
    $graphics.FillRectangle([System.Drawing.SolidBrush]::new($batteryColor), 2, 2, [int](12 * ($BatteryLevel / 100)), 12)

    $icon
}


# Create a NotifyIcon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$notifyIcon.Text = "Battery Level"
$notifyIcon.Visible = $true


# Set up the NotifyIcon
$notifyIcon.Visible = $true
$notifyIcon.add_click(
    {
        $notifyIcon.ShowBalloonTip(5000, "Battery Level Notification", $notifyIcon.Text, [System.Windows.Forms.ToolTipIcon]::Info)
        $notifyIcon.Visible = $false
        $notifyIcon.Dispose()
        [System.Windows.Forms.Application]::Exit()
    }
)



# Function to update the tray icon with the battery level
function Update-Icon {
    $deviceName = "MX Master 3S M"
    $batteryLevel = Get-BluetoothDeviceBatteryLevel -DeviceFriendlyName $deviceName

    if ($null -ne $batteryLevel) {
        $notifyIcon.Icon = [System.Drawing.Icon]::FromHandle((Get-BatteryIcon -BatteryLevel $batteryLevel).GetHicon())
        $notifyIcon.Text = "Battery Level of ${deviceName}: ${batteryLevel}%"
    } else {
        $notifyIcon.Icon = [System.Drawing.SystemIcons]::Error
        $notifyIcon.Text = "Battery Level information not available"
    }
}

# Set up a timer to update the icon every 5 minutes
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 300000 # 5 minutes in milliseconds
$timer.Add_Tick({ Update-Icon })
$timer.Start()

# Initial update
Update-Icon

# Keep the script running
[System.Windows.Forms.Application]::Run()
