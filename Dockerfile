####
#### Download and prepare PostgreSQL for Windows
####
# FROM mcr.microsoft.com/windows/servercore
FROM microsoft/windowsservercore



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
# RUN powershell Expand-Archive 'C:\\EnterpriseDB.zip'-Force -DestinationPath /postgresql
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


# RUN powershell Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices' -Name 'G:' -Value "\??\C:\sql" -Type String;  


# RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v8.1.1568/gvim_8.1.1568_x64.zip' -OutFile 'C:\\vim.zip'
# RUN powershell Expand-Archive 'C:\\vim.zip'-Force -DestinationPath /vim

# ENV POSTGRES_USER postgres


# ENV PGDATA C:\\sql
ENV PGDATA C:\\pgsql\\data
# VOLUME C:\\sql
ENV PGPORT 5432
#not using PGUSER here due to need to run createuser downstream to create role
# ENV PGUSER postgres
# ENV PGUSERVAR postgres
# ENV POSTGRES_PASSWORD postgres
ENV POSTGRES_PASSWORD postgres
ENV POSTGRES_USER postgres

RUN setx /M PATH "C:\\pgsql\\bin;%PATH%"

# WORKDIR /pgsql/bin
# RUN powershell $env:PGDATA='C:/data' ; \
#                 ./pg_ctl init -U ContainerAdministrator ; \
#                 add-content (join-path $env:PGDATA 'pg_hba.conf') '' ; \
#                 add-content (join-path $env:PGDATA 'pg_hba.conf') 'local   all             all                                     trust' ; \
#                 add-content (join-path $env:PGDATA 'pg_hba.conf') 'host    all             all             samehost                trust' ; \
#                 add-content (join-path $env:PGDATA 'postgresql.conf') '' ; \
#                 add-content (join-path $env:PGDATA 'postgresql.conf') 'listen_addresses = "*"' ; \
#                 add-content 'C:/build_version' ('Enterprise DB version: {0} ;; Docker Image Build date:{1}' -f $env:EDB_VER , ( Get-Date ) ) ; \
#                 ./pg_ctl register

# USER ContainerAdministrator

# RUN powershell get-ChildItem -path C:/ ;
# RUN if NOT exist %PGDATA% ( \
#     mkdir %PGDATA% \
# ) 

# RUN dir %PGDATA%


# RUN icacls "%PGDATA%" /grant "%USERNAME%":(OI)(CI)F > NUL

# copy dependent script(s)
# COPY . /install


# init postgresql db cluster, config and create and start service
# RUN powershell /install/init-config-start-service %PGDATA% %PGUSERVAR%

# start postgreSQL using the designated data dir
# CMD powershell /install/start detached %PGDATA% %PGUSERVAR%

COPY docker-entrypoint.cmd /
ENTRYPOINT ["C:\\docker-entrypoint.cmd"]

EXPOSE 5432
CMD ["postgres"]


