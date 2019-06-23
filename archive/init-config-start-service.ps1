# postgres init, config and start-service

param(
[string]$sqldata="c:\sql",
[string]$pguser
)

set-strictmode -version latest
$ErrorActionPreference = "Stop"

Write-Host "running init-config-start-service.ps1 with`n`tsqldata=$sqldata `n`t`tand `n`tpguser=$pguser"


$svcname = "PostgreSQL"

# create database cluster folder
./pg_ctl init -U $pguser
if ($LASTEXITCODE -ne 0) {
    Write-Error "Could not initdb with ./pg_ctl init -U $pguser ;`n==== Error(s) Dump ===="
    $Error | write-output 
    write-output "`n==== End Error Dump ===="
    # exit 1
}
# write-host "Get-Variable START >>>>>>"
# Get-ChildItem env:
# write-host "<<<<<< END Get-Variable"

# write-host "Get-Variable START >>>>>>"
# Get-Variable
# write-host "<<<<<< END Get-Variable"

# reconfigure postgresql for remote access (from default localhost-only)
# add-content (join-path $sqldata "pg_hba.conf") "`nlocal all all trust"
add-content (join-path $sqldata "pg_hba.conf") "`nhost all all samehost trust"
# add-content (join-path $sqldata "pg_hba.conf") "`nhost all all 0.0.0.0/0 trust"
# add-content (join-path $sqldata "pg_hba.conf") "`nhost all all 0.0.0.0/0 md5"

#testing
# write-host "contents of pg_hba.conf START >>>>>>"
# get-content (join-path $sqldata "pg_hba.conf") | write-host
# write-host "<<<<<< END contents of pg_hba.conf"

# write-host "contents of postgresql.conf START >>>>>>"
add-content (join-path $sqldata "postgresql.conf") "`nlisten_addresses = '*'"
#testing
# get-content (join-path $sqldata "postgresql.conf") | write-host
# write-host "<<<<<< END contents of postgresql.conf"



# create service (leaves set to 'Automatic' start)
./pg_ctl register
if ($LASTEXITCODE -ne 0) {
    Write-Error "Could not register service with ./pg_ctl register ;`n==== Error(s) Dump ===="
    $Error | write-output 
    write-output "`n==== End Error Dump ===="
    # exit 1
}