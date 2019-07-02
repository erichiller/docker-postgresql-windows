####
#### Download and prepare PostgreSQL for Windows
####
FROM microsoft/windowsservercore

LABEL maintainer="eric@hiller.pro"

# Set the variables for EnterpriseDB
ENV EDB_VER 11.4-1
ENV EDB_REPO https://get.enterprisedb.com/postgresql

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri $('{0}/postgresql-{1}-windows-x64-binaries.zip' -f $env:EDB_REPO,$env:EDB_VER) -OutFile 'C:\\EnterpriseDB.zip'
RUN powershell Expand-Archive 'C:\\EnterpriseDB.zip'-Force -DestinationPath 'C:\\'
RUN powershell Remove-Item -Path 'C:\\EnterpriseDB.zip'

# Install correct Visual C++ Redistributable Package
RUN powershell Write-Host('Visual C++ 2017 Redistributable Package') ; \
        $URL2 = 'https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe' ; \
        Invoke-WebRequest -Uri $URL2 -OutFile 'C:\\vcredist.exe' ; \
        Start-Process 'C:\\vcredist.exe' -Wait \
            -ArgumentList @( \
                '/install', \
                '/passive', \
                '/norestart' \
            ); \
        Copy-Item 'C:\\windows\\system32\\vcruntime140.dll' -Destination 'C:\\pgsql\\bin\\vcruntime140.dll' ;

ENV PGDATA C:\\pgsql\\data
ENV PGPORT 5432
ENV POSTGRES_PASSWORD postgres
ENV POSTGRES_USER postgres

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v8.1.1568/gvim_8.1.1568_x64.zip' -OutFile 'C:\\vim.zip'
RUN powershell Expand-Archive 'C:\\vim.zip'-Force -DestinationPath /vim

RUN setx /M PATH "C:\\pgsql\\bin;C:\\vim\\vim\\vim81;%PATH%"

COPY docker-entrypoint.cmd /
COPY docker-run.ps1 /
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
ENTRYPOINT ["C:\\docker-entrypoint.cmd"]

EXPOSE 5432
# CMD ["powershell", "C:\\docker-start.ps1"]
CMD ["powershell", "C:\\docker-run.ps1"]


