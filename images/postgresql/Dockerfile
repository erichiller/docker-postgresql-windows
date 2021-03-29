# escape=`
####
#### Download and prepare PostgreSQL for Windows
####
FROM mcr.microsoft.com/windows/servercore:ltsc2019


LABEL maintainer="eric@hiller.pro"
LABEL description="PostgreSQL on Windows with Volume; works with Windows Server 2019"
# Set the variables for EnterpriseDB
# See available versions here : https://www.enterprisedb.com/download-postgresql-binaries
ARG EDB_VER
ENV EDB_REPO https://get.enterprisedb.com/postgresql

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    Invoke-WebRequest -Uri $('{0}/postgresql-{1}-windows-x64-binaries.zip' -f $env:EDB_REPO,$env:EDB_VER) -OutFile 'C:\\EnterpriseDB.zip' ;
RUN powershell Expand-Archive 'C:\\EnterpriseDB.zip'-Force -DestinationPath 'C:\\'
RUN powershell Remove-Item -Path 'C:\\EnterpriseDB.zip'

# Install correct Visual C++ Redistributable Package
RUN powershell Write-Host('Visual C++ 2017 Redistributable Package') ; `
        $URL2 = 'https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe' ; `
        Invoke-WebRequest -Uri $URL2 -OutFile 'C:\\vcredist.exe' ; `
        Start-Process 'C:\\vcredist.exe' -Wait `
            -ArgumentList @( `
                '/install', `
                '/passive', `
                '/norestart' `
            ); `
        Copy-Item 'C:\\windows\\system32\\vcruntime140.dll' -Destination 'C:\\pgsql\\bin\\vcruntime140.dll' ;

ENV PGDATA C:\pgsql\data
ENV PGPORT 5432
ENV POSTGRES_PASSWORD postgres
ENV POSTGRES_USER postgres


# <!----- TESTING ONLY ------>

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v8.1.1568/gvim_8.1.1568_x64.zip' -OutFile 'C:\\vim.zip' ;
RUN powershell -Command `
    Expand-Archive 'C:\\vim.zip'-Force -DestinationPath 'C:\\vim' ; `
    ls C:\\ ; `
    ls C:\\vim ; `
    ls C:\\vim\\vim ;

RUN powershell setx /M PATH ( 'C:\pgsql\bin;C:\vim\vim\vim81;{0}' -f $env:PATH )

# <---- END TESTING ONLY ----->



COPY docker-entrypoint.cmd /
COPY docker-run.ps1 /
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
ENTRYPOINT C:\\docker-entrypoint.cmd

EXPOSE 5432
CMD powershell -Command C:\\docker-run.ps1