# create postgres role then do appropriate detached / interactive action

param(
[ValidateSet('interactive', 'detached', ignorecase=$true)]
[string]$attachmode="interactive",
[string]$sqldata="c:\sql",
[string]$pguser="postgres"
)

set-strictmode -version latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
$WarningPreference = "Continue"

Write-Host "running start.ps1 with`n`tattachmode=$attachmode `n`t`tand`n`tsqldata=$sqldata `n`t`tand `n`tpguser=$pguser"

$pgHbaLdapString = "`nhost    all             all             0.0.0.0/0               ldap    ldapserver=deepthought.hiller.pro ldapbasedn=`"CN=Users,DC=hiller,DC=pro`" ldapbinddn=`"cn=$pguser,cn=Users,dc=hiller,dc=pro`" ldapbindpasswd=`"$env:POSTGRES_PASSWORD`" ldapsearchattribute=`"sAMAccountName`""

if ( -not ( (test-path (join-path $env:PGDATA "pg_hba.conf")) -and (test-path (join-path $env:PGDATA "postgresql.conf")) -and (test-path (join-path $env:PGDATA "PG_VERSION")) ) ){
  # copy data over
  Copy-Item -Recurse "C:\data\*" $env:PGDATA
  # if ( -not ( test-path $env:PGDATA ) ){
  #   Write-Host "$env:PGDATA was not detected, creating"
  #   mkdir $env:PGDATA
  #   if ( -not ( test-path $env:PGDATA ) ){
  #     Write-Error "!!!! Failed to create the directory $env:PGDATA"
  #     exit 1;
  #   }
  # }
  # . /install/init-config-start-service $env:PGDATA $pguser
  Write-Host "adding to $(join-path $env:PGDATA 'pg_hba.conf'): $pgHbaLdapString"
  Add-Content (join-path $env:PGDATA "pg_hba.conf") $pgHbaLdapString
} else {
  Write-Host "pg_hba.conf already configured" 
}
  # C:/postgresql/pgsql/bin/pg_ctl -D C:/data -l logfile start

Write-Host -NoNewline "Checking if postgresql service is registered".PadRight(50,".");
if ( get-service -name postgresql ) {
  Write-Host -NoNewline "[" ; Write-Host -NoNewline -ForegroundColor green OK ; Write-Host "]" ;
} else {
  Write-Host -NoNewline "[" ; Write-Host -NoNewline -ForegroundColor red FAIL ; Write-Host "]" ;
}


Write-Host "Starting PostgreSQL Service".PadRight(50,".");

if(Start-Service PostgreSQL){ 
  Write-Host -NoNewline "[" ; Write-Host -NoNewline -ForegroundColor green OK ; Write-Host "]" ;
} else { 
  Write-Host -NoNewline "[" ; Write-Host -NoNewline -ForegroundColor red FAIL ; Write-Host "]" ;
  exit 1;
}
# ensure it started properly
Write-Host "Checking for proper start".PadRight(50,".");
if(Get-Process -Name postgres){ 
  Write-Host -NoNewline "[" ; Write-Host -NoNewline -ForegroundColor green OK ; Write-Host "]" ;
} else { 
  Write-Host -NoNewline "[" ; Write-Host -NoNewline -ForegroundColor red FAIL ; Write-Host "]" ;
  exit 1;
}


#testing
write-host "contents of pg_hba.conf START >>>>>>"
get-content (join-path $sqldata "pg_hba.conf") | write-host
write-host "<<<<<< END contents of pg_hba.conf"


# create postgres role for postgres user / db if needed (first time this script is run in container)
Write-Output "creating roles ./psql -U $pguser -d $pguser -c `"\c $pguser`""
./psql -U $pguser -d $pguser -c "\c $pguser" 
if ($LASTEXITCODE -ne 0) {
  Write-Warning "!! Could not setup with ./psql -U $pguser -d $pguser -c `"\c $pguser`" ;`n==== Error(s) Dump ===="
  $Error | write-output 
  write-output "`n==== End Error Dump ===="
  write-output "Attempting to create user $pguser with ./createuser -s -r $pguser"
  exit 1;
  ./createuser -s -r $pguser
  if ($LASTEXITCODE -ne 0) {
    Write-Error "!!!! './createuser -s -r $pguser' failed : could not create role;`n==== Error(s) Dump ===="
    $Error | write-output 
    write-output "`n==== End Error Dump ===="
    exit 1
  }
  else {
    Write-Output "$pguser successfully created"
  }
}

# take interactive / detached action as appropriate
if ($attachmode -eq "interactive") {
  powershell
}
else {
 # sleep-loop indefinitely (until container stop)
 while (1 -eq 1) {
   [DateTime]::Now.ToShortTimeString()
   Start-Sleep -Seconds 10
  }
}