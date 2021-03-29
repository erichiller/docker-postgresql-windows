

Write-Host -ForegroundColor Gray "Setting up pgadmin..."


Write-Host "Count: $($args.Count)"

Write-Host "Passed arguments:" ;
$args | foreach-object {
    Write-Host "`t"$_ ;
}

# testing
$env:CURL_CA_BUNDLE = ""

Write-Host "Environment Variables; "
Get-ChildItem Env: | ForEach-Object { Write-Host "$($_.Name.PadRight(40)) = $($_.Value)" }

$env:PGADMIN_SETUP = Join-Path $env:PGADMIN_DIR 'setup.py'
# $env:PGADMIN_TEMP_PASS_FILE = Join-Path $env:PGADMIN_DATA_DIR 'pass.txt'

Write-Host -ForegroundColor Gray "Running with Environment variables".PadRight(60)
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_DATA_DIR".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_DATA_DIR
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_DIR".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_DIR
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_SETUP".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_SETUP
Write-Host -ForegroundColor Gray -NoNewline "HOSTNAME".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:HOSTNAME
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_APP_NAME".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_APP_NAME

Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_LDAP_AUTO_CREATE_USER".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_LDAP_AUTO_CREATE_USER
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_LDAP_BIND_USER".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_LDAP_BIND_USER
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_LDAP_SERVER_URI".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_LDAP_SERVER_URI
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_LDAP_USERNAME_ATTRIBUTE".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_LDAP_USERNAME_ATTRIBUTE
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_LDAP_SEARCH_BASE_DN".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_LDAP_SEARCH_BASE_DN
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_LDAP_SEARCH_FILTER".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_LDAP_SEARCH_FILTER
Write-Host -ForegroundColor Gray -NoNewline "PGADMIN_CONFIG_LDAP_SEARCH_SCOPE".PadRight(40) ": " ; Write-Host -ForegroundColor White $env:PGADMIN_CONFIG_LDAP_SEARCH_SCOPE


Write-Host -ForegroundColor Gray -NoNewline "Checking for Existing Data Directory...".PadRight(60)
if ( -not ( test-path -Path $env:PGADMIN_DATA_DIR ) ) {
    Write-Host -ForegroundColor White "[ NOT FOUND ]"
    Write-Host -ForegroundColor Gray "Creating Data Directory: $($env:PGADMIN_DATA_DIR)"
    New-Item -Path $env:PGADMIN_DATA_DIR -Force -ItemType Directory
}


Write-Host -ForegroundColor Gray -NoNewline "Checking for Existing Configuration...".PadRight(60)
if ( -not ( test-path $env:PGADMIN_SQLITE_PATH) ) {
    Write-Host -ForegroundColor White "[ NOT FOUND ]"
    Write-Host -ForegroundColor Gray "Adding Configuration for local deployment".PadRight(60)
    if (( -not (Test-Path env:PGADMIN_DEFAULT_USER)) -or ( -not (Test-Path env:PGADMIN_DEFAULT_PASSWORD)) ) { 
        Write-Host -ForegroundColor Red 'You need to specify PGADMIN_DEFAULT_USER and PGADMIN_DEFAULT_PASSWORD environment variables'
        exit 1
    }

    Write-Host -ForegroundColor Gray -NoNewline "Checking TLS (TLS support is not implemented)...".PadRight(60)
    if ( $env:PGADMIN_ENABLE_TLS -eq "True" ) {
        Write-Host -ForegroundColor Red "[ Fail ]" 
    } else {
        Write-Host -ForegroundColor Green "[ OK ]"
    }

    # Set the default username and password in a
    # backwards compatible way
    $env:PGADMIN_SETUP_EMAIL = $env:PGADMIN_DEFAULT_USER
    $env:PGADMIN_SETUP_PASSWORD = $env:PGADMIN_DEFAULT_PASSWORD

    Write-Host -ForegroundColor Gray "checking if pgAdmin's setup.py has run before...".PadRight(60)
    if ( -not ( Test-Path -Path $env:PGADMIN_SQLITE_PATH ) ) {
        Write-Host -ForegroundColor Yellow "Could not load existing configuration." 
        Write-Host -ForegroundColor Gray "Running pgAdmin4 setup.py...".PadRight(60)
        python $env:PGADMIN_SETUP
        if ( $? ) {
            Write-Host -ForegroundColor Green "[ OK ]"
        } else {
            Write-Host -ForegroundColor Red "[ Fail ]"
            exit 1;
        }
    }
    # if ( $( . python "$env:PGADMIN_SETUP" --dump-servers "$($env:PGADMIN_SERVER_JSON_FILE)" --user $env:PGADMIN_DEFAULT_USER ) -and
    #     ( Test-Path "$($env:PGADMIN_SERVER_JSON_FILE)" ) ) {
    #     Write-Host -ForegroundColor Green -NoNewline "Found existing servers: ".PadRight(60)
    #     Get-Content "$($env:PGADMIN_SERVER_JSON_FILE)" | ForEach-Object {
    #         Write-Host -ForegroundColor Gray -NoNewline "`t> $($_)"
    #     }
    # } else {
    #     Write-Host -ForegroundColor Yellow "Existing configuration not found." 
    # Pre-load any required servers
    if ( Test-Path 'env:POSTGRES_HOST' ) { 
        Write-Host -ForegroundColor Cyan -NoNewline "Found server setting environment variables. Importing...".PadRight(60)
        # Set-Content -Path "$($env:PGADMIN_TEMP_PASS_FILE)" -Value $env:PGADMIN_DEFAULT_PASSWORD ;
        @{
            "Servers" = @{
                "1" = @{
                    "Name" = "pg"
                    "Group"         = "Servers"
                    "Host"          = $env:POSTGRES_HOST
                    "Port"          = $env:POSTGRES_PORT
                    "MaintenanceDB" = "postgres"
                    "Username"      = $env:PGADMIN_DEFAULT_USER
                    "SSLMode"       = "prefer"
                    "SSLCert"       = "<STORAGE_DIR>\\.postgresql\\postgresql.crt"
                    "SSLKey"        = "<STORAGE_DIR>\\.postgresql\\postgresql.key"
                    "SSLCompression"= 0
                    "Timeout"       = 10
                    "UseSSHTunnel"  = 0
                    "TunnelPort"    = "22"
                    "TunnelAuthentication" = 0
                }
            }
        } | ConvertTo-Json | Set-Content -Path "$($env:PGADMIN_SERVER_JSON_FILE)"
        python "$env:PGADMIN_SETUP" --load-servers "$($env:PGADMIN_SERVER_JSON_FILE)" --user $env:PGADMIN_DEFAULT_USER
        if ( $? ) {
            Write-Host -ForegroundColor Green "[ OK ]"
        } else {
            Write-Host -ForegroundColor Red "[ Fail ]"
            exit 1;
        }
    } else {
        Write-Host -ForegroundColor Gray -NoNewline "No server settings detected. Continuing...".PadRight(60)
    }
    # }
} else {
    Write-Host -ForegroundColor White "[ FOUND ]"
}

Write-Host -ForegroundColor Green "Starting..."

# Run CMD ( from Dockerfile )
[String]::Join(" ", $args) | Invoke-Expression
