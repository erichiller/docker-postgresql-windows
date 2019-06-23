
set-strictmode -version latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
$WarningPreference = "Continue"

# Write-Host "pgsql-configure being called."
# . "C:\pgsql-configure.cmd"

if ( -not ( get-service -name PostgreSQL -ErrorAction Continue ) ){
    Write-Host "registering service"
    pg_ctl register
}
    

Write-Host "Starting service ..."
Start-Service PostgreSQL
Get-EventLog -LogName System -After (Get-Date).AddHours(-1) | Format-List
$idx = (get-eventlog -LogName System -Newest 1).Index
while ($true) {
    start-sleep -Seconds 1
    $idx2 = (Get-EventLog -LogName System -newest 1).index
    get-eventlog -logname system -newest ($idx2 - $idx) | sort index | Format-List
    $idx = $idx2
}