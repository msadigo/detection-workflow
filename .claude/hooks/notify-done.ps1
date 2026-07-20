$title = "Claude Code"
$message = "Claude has finished responding."

$burntToast = Get-Module -ListAvailable -Name BurntToast
if ($burntToast) {
    Import-Module BurntToast
    New-BurntToastNotification -Text $title, $message
} else {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    Add-Type -AssemblyName System.Drawing | Out-Null

    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
    $notifyIcon.Visible = $true
    $notifyIcon.BalloonTipTitle = $title
    $notifyIcon.BalloonTipText = $message
    $notifyIcon.ShowBalloonTip(3000)

    Start-Sleep -Milliseconds 3500
    $notifyIcon.Dispose()
}
