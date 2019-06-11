####
#### Download and prepare PostgreSQL for Windows
####
# FROM mcr.microsoft.com/windows/servercore
FROM microsoft/windowsservercore

# Set the variables for EnterpriseDB
ENV EDB_VER 11.3-4
ENV EDB_REPO https://get.enterprisedb.com/postgresql


##### Use PowerShell for the installation
# SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

## https://get.enterprisedb.com/postgresql/postgresql-11.3-4-windows-x64.exe
# msiexec.exe /l* /quiet /i .\postgresql-11.3-4-windows-x64.exe 
### Download EnterpriseDB and remove cruft
# RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
#     $URL1 = $('{0}/postgresql-11.3-4-windows-x64.exe' -f $env:EDB_REPO,$env:EDB_VER) ; \
#     Invoke-WebRequest -Uri $URL1 -OutFile 'C:\\EnterpriseDB.exe' ;

# RUN msiexec.exe /l* /quiet /i C:\\EnterpriseDB.exe ;
# RUN Get-ChildItem C:\\ | Write-Output ;
# RUN Get-ChildItem 'C:\\Program Files\\' | Write-Output ;
# RUN Get-ChildItem 'C:\\Program Files (x86)\\' | Write-Output ;

# https://www.enterprisedb.com/download-postgresql-binaries
# http://get.enterprisedb.com/postgresql/postgresql-11.3-4-windows-x64-binaries.zip
RUN powershell 

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri $('{0}/postgresql-{1}-windows-x64-binaries.zip' -f $env:EDB_REPO,$env:EDB_VER) -OutFile 'C:\\EnterpriseDB.zip'
RUN powershell Expand-Archive 'C:\\EnterpriseDB.zip'-Force -DestinationPath /postgresql
RUN powershell Remove-Item -Path 'C:\\EnterpriseDB.zip'

ENV PGDATA c:\\sql
ENV PGPORT 5432
#not using PGUSER here due to need to run createuser downstream to create role
ENV PGUSERVAR postgres


#install VC 2013 runtime required by postgresql
#use chocolatey pkg mgr to facilitate command-line installations
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
RUN choco install vcredist2013 -y

# copy dependent script(s)
COPY . /install

WORKDIR /postgresql/pgsql/bin

# init postgresql db cluster, config and create and start service
RUN powershell /install/init-config-start-service %PGDATA% %PGUSERVAR%

# start postgreSQL using the designated data dir
CMD powershell /install/start detached %PGDATA% %PGUSERVAR%