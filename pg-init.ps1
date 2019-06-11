$env:POSTGRES_INITDB_ARGS='--pwfile="C:\.pgpass"'
write-output "POSTGRES_INITDB_ARGS is $env:POSTGRES_INITDB_ARGS"
write-output "PGDATA is $env:PGDATA"
write-output "POSTGRES_USER is $env:POSTGRES_USER"
write-output "POSTGRES_PASSWORD is $env:POSTGRES_PASSWORD"

if ( test-path $env:PGDATA ){
    write-output "$env:PGDATA exists"
} else {
    New-Item -Path C:/.pgpass
    Add-Content -Path C:/.pgpass -Value $env:POSTGRES_PASSWORD

    New-Item -Path $env:PGDATA -ItemType Directory


    initdb -U $env:POSTGRES_USER -E UTF8 --no-locale -D $env:PGDATA $env:POSTGRES_INITDB_ARGS



}

Get-ChildItem $env:PGDATA
Get-ChildItem C:/pgsql

$auth_method="md5"
write-output "auth_method is $auth_method"

if ( -not (Test-Path $env:PGDATA\pg_hba.conf) ){
    New-Item -Path $env:PGDATA\pg_hba.conf -ItemType File
}
Add-Content -Path $env:PGDATA\pg_hba.conf -Value "host all all all $auth_method"

Get-Content $env:PGDATA\pg_hba.conf

pg_ctl register -N postgresql -S auto


# Invoke-Command { pg_ctl -U postgres -D c:\pgsql\data -w start }

# postgres --help
# postgres -d 5

# Invoke-Command { postgres.exe }


# write-output heeeeee

# ping google.com
# ping google.com
# ping google.com