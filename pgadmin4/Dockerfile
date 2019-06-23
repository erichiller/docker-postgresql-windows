####
#### Download and prepare PostgreSQL for Windows
####
# FROM mcr.microsoft.com/windows/servercore
FROM microsoft/windowsservercore


ENV PGDATA C:\\sql
ENV PGPORT 5432
#not using PGUSER here due to need to run createuser downstream to create role
# ENV PGUSER postgres
ENV PGUSERVAR postgres
# ENV POSTGRES_PASSWORD postgres
ENV POSTGRES_PASSWORD postgres

# VOLUME "C:\sql"

# RUN mkdir $PGDATA


# Set the variables for EnterpriseDB
ENV EDB_VER 11.3-4
ENV EDB_REPO https://get.enterprisedb.com/postgresql


# https://github.com/jupyter/docker-stacks
# https://hub.docker.com/_/python/

# .\jupyter-lab.exe --help-all
# https://jupyterlab.readthedocs.io/en/stable/index.html

# https://docs.docker.com/engine/reference/commandline/cli/

# Build with docker image build . -t ehiller/jupyterlab-windows2016-python3.7.2:latest
# run with docker run -d -p 8888:8888 --name jupyterlab --restart always -v S:\virtual_machines\containers\jupyterlab:C:\Data ehiller/jupyterlab-windows2016-python3.7.2:latest


# docker run -it -p 5432:5432 ehiller/postgresql "powershell"





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

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri $('{0}/postgresql-{1}-windows-x64-binaries.zip' -f $env:EDB_REPO,$env:EDB_VER) -OutFile 'C:\\EnterpriseDB.zip'
RUN powershell Expand-Archive 'C:\\EnterpriseDB.zip'-Force -DestinationPath /postgresql
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
            )


# RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v8.1.1568/gvim_8.1.1568_x64.zip' -OutFile 'C:\\vim.zip'
# RUN powershell Expand-Archive 'C:\\vim.zip'-Force -DestinationPath /vim

# copy dependent script(s)
COPY . /install

WORKDIR /postgresql/pgsql/bin

RUN mkdir C:/sql
VOLUME C:/sql

# init postgresql db cluster, config and create and start service
RUN powershell /install/init-config-start-service %PGDATA% %PGUSERVAR%

# start postgreSQL using the designated data dir
CMD powershell /install/start detached %PGDATA% %PGUSERVAR%