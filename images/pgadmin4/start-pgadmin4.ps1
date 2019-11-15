Write-Host -ForegroundColor Gray "Beginning Apache startup..."

$env:APACHE_CONFIG = 'C:/Apache24/conf/httpd.conf';

$env:PGADMIN_WSGI = 'C:\pgsql\pgAdmin 4\web\pgAdmin4.wsgi'

$env:PGADMIN_ACTIVATE = 'C:/pgsql/pgAdmin 4/venv/Scripts/activate_this.py'

$env:PGADMIN_SETUP = 'C:/pgsql/pgAdmin 4/web/setup.py'

$env:APACHE_LOG_DIR = 'C:/data/apache/logs/';



Write-Host -ForegroundColor Gray "Running with Environment variables".PadRight(60)
Write-Host -ForegroundColor Gray -NoNewline "APACHE_CONFIG".PadRight(40) ":".PadRight(19) ; Write-Host -ForegroundColor White $env:APACHE_CONFIG
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_WSGI".PadRight(40) ":".PadRight(19) ; Write-Host -ForegroundColor White $env:PGADMIN_WSGI
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_ACTIVATE".PadRight(40) ":".PadRight(19) ; Write-Host -ForegroundColor White $env:PGADMIN_ACTIVATE
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_SETUP".PadRight(40) ":".PadRight(19) ; Write-Host -ForegroundColor White $env:PGADMIN_SETUP
Write-Host -ForegroundColor Gray -NoNewline "APACHE_LOG_DIR".PadRight(40) ":".PadRight(19) ; Write-Host -ForegroundColor White $env:APACHE_LOG_DIR

if ( -not (  (Get-Content $env:APACHE_CONFIG ) -like '*Directory C:/pgsql/pgAdmin 4/web*')  ) {

    if ( -not ( test-path $env:APACHE_LOG_DIR ) ) {
        mkdir -Path "C:\data\apache\logs"
    }
    Add-Content -Path $env:APACHE_CONFIG -Value @"


LogFormat "%h %l %u %t %r    %b %{Referer}i %{User-agent}i" combined
CustomLog C:/data/apache/logs/combined.log combined

ErrorLog C:/data/apache/logs/error.log
# ErrorLog logs/combined.log

ServerName $env:HOSTNAME

WSGIVerboseDebugging On

# ErrorLog "|more"


<VirtualHost *>
    ServerName $env:HOSTNAME

    # WSGIDaemonProcess pgadmin processes=1 threads=$env:THREADS
    WSGIScriptAlias / "C:\pgsql\pgAdmin 4\web\pgAdmin4.wsgi"

    <Directory "C:\pgsql\pgAdmin 4\web">
        # WSGIProcessGroup pgadmin
        # WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
</VirtualHost>
"@
}


if ( -not (  (Get-Content $env:PGADMIN_WSGI ) -like "*activate_this = `"C:\pgsql\pgAdmin 4\venv\Scripts\activate_this.py`"*")  ) {
    
    @"
from pathlib import Path
activate_this = Path("$env:PGADMIN_ACTIVATE")
exec(open(activate_this).read())
"@ + "`n" + ( (Get-Content $env:PGADMIN_WSGI) -join "`n" ) | Set-Content $env:PGADMIN_WSGI
}


if ( -not (  (Get-Content $env:PGADMIN_ACTIVATE ) -like "*site_packages = os.path.join(base, 'venv', 'Lib', 'site-packages')*")  ) {
    Write-Host "Applying fix to environment activation script 'activate_this.py'"
    ((Get-Content -path $env:PGADMIN_ACTIVATE -Raw).replace("site_packages = os.path.join(base, 'Lib', 'site-packages')", "site_packages = os.path.join(base, 'venv', 'Lib', 'site-packages')") | Set-Content -Path $env:PGADMIN_ACTIVATE)

}


Write-Host -ForegroundColor Gray -NoNewline "Adding Configuration for local deployment"
if ( -not ( test-path ( join-path $env:PGADMIN_DATA_DIR 'pgadmin4.db' ) ) ) {
    Write-Host -ForegroundColor White "[ NOT FOUND ]"
    Write-Host -ForegroundColor Gray "Adding Configuration for local deployment"
    Set-Content -Path $env:PGADMIN_CONFIG_PATH -Value @"
SERVER_MODE = True
X_FRAME_OPTIONS = ""

DATA_DIR = "$env:PGADMIN_DATA_DIR"

LOG_FILE = "$(join-path $env:PGADMIN_DATA_DIR 'pgadmin4.log')"
SQLITE_PATH = "$(join-path $env:PGADMIN_DATA_DIR 'pgadmin4.db')"
SESSION_DB_PATH = "$(join-path $env:PGADMIN_DATA_DIR 'sessions')"
STORAGE_DIR = "$(join-path $env:PGADMIN_DATA_DIR 'storage')"
"@

    if (( -not (Test-Path env:PGADMIN_DEFAULT_EMAIL)) -or ( -not (Test-Path env:PGADMIN_DEFAULT_PASSWORD)) ) { 
        Write-Host -ForegroundColor Red 'You need to specify PGADMIN_DEFAULT_EMAIL and PGADMIN_DEFAULT_PASSWORD environment variables'
        exit 1
    }

    # Set the default username and password in a
    # backwards compatible way
    $env:PGADMIN_SETUP_EMAIL = $env:PGADMIN_DEFAULT_EMAIL
    $env:PGADMIN_SETUP_PASSWORD = $env:PGADMIN_DEFAULT_PASSWORD

    # Initialize DB before starting Gunicorn
    # Importing pgadmin4 (from this script) is enough
    python run_pgadmin.py
}

# if ( -not ( test-path ( join-path $env:PGADMIN_DATA_DIR 'pgadmin4.db' ) ) ) {
Write-Host -ForegroundColor Gray -NoNewline "checking if pgAdmin's setup.py has run before...".PadRight(60)

if ( $(( '{0};{1}' -f ( 'C:\\pgsql\\pgAdmin 4\\venv\\Lib\\site-packages', ( python -c 'import sys; print(chr(59).join(x for x in sys.path if x))') ) ) ; python "$env:PGADMIN_SETUP" --dump-servers )) {
    Write-Host -ForegroundColor Yellow "NOTE TO SELF::: WITH THE PROPER PYTHON PATH setup.py ran"
}

if ( $( . python "$env:PGADMIN_SETUP" --dump-servers ) ) {
    Write-Host -ForegroundColor Green "[ OK ]"
} else {
    Write-Host -ForegroundColor Red "[ Fail ]" 
    # Pre-load any required servers
    if ( test-path "$env:PGADMIN_SERVER_JSON_FILE}" ) {
        Write-Host -ForegroundColor Gray -NoNewline "Found servers json file, adding...".PadRight(60)
        python "$env:PGADMIN_SETUP" --load-servers "$env:PGADMIN_SERVER_JSON_FILE" --user $env:PGADMIN_DEFAULT_EMAIL
        if ( $? ) {
            Write-Host -ForegroundColor Green "[ OK ]"
        } else {
            Write-Host -ForegroundColor Red "[ Fail ]"
            exit 1;
        }
    }
    Write-Host -ForegroundColor Gray "Running pgAdmin4 setup.py...".PadRight(60)
    $env:PYTHONPATH = ( '{0};{1}' -f ( 'C:\\pgsql\\pgAdmin 4\\venv\\Lib\\site-packages', ( python -c 'import sys; print(chr(59).join(x for x in sys.path if x))') ) ) ; python $env:PGADMIN_SETUP
    if ( $? ) {
        Write-Host -ForegroundColor Green "[ OK ]"
    } else {
        Write-Host -ForegroundColor Red "[ Fail ]"
        exit 1;
    }
}



# Write-Host " >>>>>>>> contents of '$env:PGADMIN_ACTIVATE' >>>>>>>>"
# cat $env:PGADMIN_ACTIVATE
# Write-Host " <<<<<<<< END contents of '$env:PGADMIN_ACTIVATE' <<<<<<<<"

# #### TESTING !!!!!
# Write-Host " >>>>>>>> contents of '$env:PGADMIN_WSGI' >>>>>>>>"
# cat $env:PGADMIN_WSGI
# Write-Host " <<<<<<<< END contents of '$env:PGADMIN_WSGI' <<<<<<<<"

if ( $env:PGADMIN_ENABLE_TLS -eq "True" ) {
    Write-Error "TLS not currently supported"
} else {
    Write-Host "Starting Apache..."
    . /Apache24/bin/httpd.exe -e Debug
    Get-Content -Tail "C:/data/apache/logs/error.log"
}

# ( .\httpd.exe -e DEBUG -L ) -like "*WSGI*"



# @("Line 1 text", "Line 2 text") +  (Get-Content "C:\pgsql\pgAdmin 4\web\pgAdmin4.wsgi") | Set-Content "C:\pgsql\pgAdmin 4\web\pgAdmin4.wsgi"