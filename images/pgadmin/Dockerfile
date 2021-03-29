####
#### Download and prepare PostgreSQL for Windows
####


FROM python

LABEL maintainer="eric@hiller.pro"
LABEL description="pgAdmin 4 on Windows; works with Windows Server 2019"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Set the variables for EnterpriseDB
# see https://www.enterprisedb.com/edb-docs
# downloads https://www.enterprisedb.com/download-postgresql-binaries
ARG EDB_VER
ENV EDB_REPO https://get.enterprisedb.com/postgresql

# Install Windows Root SSL certificates
RUN certutil -generateSSTFromWU roots.sst ; \
    certutil -addstore -f root roots.sst ; \
    del roots.sst ;

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri $('{0}/postgresql-{1}-windows-x64-binaries.zip' -f $env:EDB_REPO,$env:EDB_VER) -OutFile 'C:\\EnterpriseDB.zip' ; \
    Expand-Archive 'C:\\EnterpriseDB.zip'-Force -DestinationPath 'C:\\temp' ; \
    Remove-Item -Path 'C:\\EnterpriseDB.zip' ; \
    New-Item -ItemType Directory -Path 'C:\\pgsql' ; \
    Copy-Item -Recurse -Force -Path 'C:\\temp\\pgsql\\bin' -Destination 'C:\\pgsql\\bin' ; \
    Remove-Item -Force -Recurse -Path 'C:\\temp' ;


# Install correct Visual C++ Redistributable Package
RUN Write-Host('Visual C++ 2017 Redistributable Package') ; \
    # $URL2 = 'https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe' ; \
    $URL2 = 'https://download.visualstudio.microsoft.com/download/pr/366c0fb9-fe05-4b58-949a-5bc36e50e370/015EDD4E5D36E053B23A01ADB77A2B12444D3FB6ECCEFE23E3A8CD6388616A16/VC_redist.x64.exe' ; \
    Invoke-WebRequest -Uri $URL2 -OutFile 'C:\\vcredist.exe' ; \
    Start-Process 'C:\\vcredist.exe' -Wait \
    -ArgumentList @( \
    '/install', \
    '/passive', \
    '/norestart' \
    ); \
    Get-ChildItem 'C:\\Windows\\System32\\vc*' ; \
    Copy-Item 'C:\\windows\\system32\\vcruntime140.dll' -Destination 'C:\\pgsql\\bin\\vcruntime140.dll' ;

# Install ViM for TESTING
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v8.1.1568/gvim_8.1.1568_x64.zip' -OutFile 'C:\\vim.zip' ; \
    Expand-Archive 'C:\\vim.zip'-Force -DestinationPath /vim ; \
    setx /M PATH ( '{0};{1};{2}' -f ( 'C:\\pgsql\\bin', 'C:\\vim\\vim\\vim81', $env:PATH ) ) ;

# This is the email address used when setting up the initial administrator account to login to pgAdmin. This variable is required and must be set at launch time.
ENV PGADMIN_DEFAULT_USER admin

ENV POSTGRES_PORT 5432

# This is the password used when setting up the initial administrator account to login to pgAdmin. This variable is required and must be set at launch time.
ENV PGADMIN_DEFAULT_PASSWORD admin

# Set to True or False
# Not yet supported
ENV PGADMIN_ENABLE_TLS False

ENV PGADMIN_LISTEN_PORT 80

# Adjust the number of threads the server uses to handle incoming requests. This should typically be left as-is, except in highly loaded systems where it may be increased.
ENV THREADS 25

ENV HOSTNAME pgadmin4.local

ENV PGADMIN_DIR C:/Python/lib/site-packages/pgadmin4/
ENV PGADMIN_CONFIG_PATH C:/Python/lib/site-packages/pgadmin4/config_local.py

ENV PGADMIN_DATA_DIR C:/data/pgadmin4
ENV PGADMIN_SERVER_JSON_FILE ${PGADMIN_DATA_DIR}/servers.json
ENV PGADMIN_SQLITE_PATH ${PGADMIN_DATA_DIR}/pgadmin4.db

RUN python -m pip install pgadmin4 waitress

COPY pgadmin_config.py $PGADMIN_CONFIG_PATH

COPY init.ps1 /

WORKDIR ${PGADMIN_DIR}

EXPOSE $PGADMIN_LISTEN_PORT
ENTRYPOINT [ "powershell" , "C:\\init.ps1"]
# "--listen=\"*:$($env:PGADMIN_LISTEN_PORT)\"",
CMD [ "waitress-serve", "--port=$($env:PGADMIN_LISTEN_PORT)", "--threads=$($env:THREADS)", "pgAdmin4:app" ]


HEALTHCHECK --start-period=30s --interval=30s --retries=5 \
    CMD powershell -command \
    try { \
    $response = iwr -useb http://localhost; \
    if ($response.StatusCode -eq 200) { return 0 } \
    else {return 1}; \
    } catch { return 1 }