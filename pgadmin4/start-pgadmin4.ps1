$env:APACHE_CONFIG = 'C:/Apache24/conf/httpd.conf';

if ( -not (  (Get-Content $env:APACHE_CONFIG ) -like '*Directory C:/pgsql/pgAdmin 4/web*')  ){
    Add-Content -Path $env:APACHE_CONFIG -Value @"

<VirtualHost *>
    ServerName $env:HOSTNAME

    # WSGIDaemonProcess pgadmin processes=1 threads=$env:THREADS
    WSGIScriptAlias / C:/pgsql/pgAdmin 4/web/pgAdmin4.wsgi

    <Directory C:/pgsql/pgAdmin 4/web>
        # WSGIProcessGroup pgadmin
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
</VirtualHost>
"@
}


if ( $env:PGADMIN_ENABLE_TLS -eq "True" ) {
    Write-Error "TLS not currently supported"
} else {
    . /Apache24/bin/httpd.exe -w
}

# ( .\httpd.exe -e DEBUG -L ) -like "*WSGI*"