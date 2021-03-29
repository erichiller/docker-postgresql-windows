# escape=`
####
#### Download and prepare PostgreSQL for Windows
####
# FROM mcr.microsoft.com/windows/servercore:ltsc2019
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019


LABEL maintainer="eric@hiller.pro"

# Set the variables for EnterpriseDB
# ENV EDB_VER 11.4-1
ENV EDB_VER 11.5-1
ENV EDB_REPO https://get.enterprisedb.com/postgresql

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri $('{0}/postgresql-{1}-windows-x64-binaries.zip' -f $env:EDB_REPO,$env:EDB_VER) -OutFile 'C:\\EnterpriseDB.zip'
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




# <!----? TESTING ONLY ?----->

RUN powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v8.1.1568/gvim_8.1.1568_x64.zip' -OutFile 'C:\\vim.zip'
RUN powershell -Command `
    Expand-Archive 'C:\\vim.zip'-Force -DestinationPath 'C:\\vim' ; `
    ls C:\\ ; `
    ls C:\\vim ; `
    ls C:\\vim\\vim ;

RUN setx /M PATH ( 'C:\pgsql\bin;C:\vim\vim\vim81;{0}' -f $env:PATH )
# RUN [Environment]::SetEnvironmentVariable("Path", $('{0};{1};{2}' -f 'C:\pgsql\bin','C:\vim\vim\vim81',$env:Path), [EnvironmentVariableTarget]::Machine)

# <!----- TESTING ONLY ------>

ENV PYTHON_VERSION 3.6.8
ENV PYTHON_RELEASE 3.6.8

RUN Write-Host "$env:PATH"

# RUN $url = ('https://www.python.org/ftp/python/{0}/python-{1}-amd64.exe' -f $env:PYTHON_RELEASE, $env:PYTHON_VERSION); `
#     Write-Host ('Downloading {0} ...' -f $url); `
#     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
#     Invoke-WebRequest -Uri $url -OutFile 'python.exe'; `
#     `
#     Write-Host 'Installing ...'; `
#     # https://docs.python.org/3.5/using/windows.html#installing-without-ui
#     Start-Process python.exe -Wait `
#     -ArgumentList @( `
#     '/quiet', `
#     'InstallAllUsers=1', `
#     'TargetDir=C:\Python', `
#     'PrependPath=1', `
#     'Shortcuts=0', `
#     'Include_doc=0', `
#     'Include_pip=0', `
#     'Include_test=0' `
#     ); `
#     `
#     # the installer updated PATH, so we should refresh our local value
#     $env:PATH = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::Machine); `
#     `
#     Write-Host 'Verifying install ...'; `
#     Write-Host '  python --version'; python --version; `
#     `
#     Write-Host 'Removing ...'; `
#     Remove-Item python.exe -Force; `
#     `
#     Write-Host 'Complete.';

# # if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
# ENV PYTHON_PIP_VERSION 19.2.2

# RUN powershell -Command `
#     Write-Host ('Installing pip=={0} ...' -f $env:PYTHON_PIP_VERSION); `
#     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
#     Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile 'get-pip.py'; `
#     python get-pip.py `
#     --disable-pip-version-check `
#     --no-cache-dir `
#     ('pip=={0}' -f $env:PYTHON_PIP_VERSION) `
#     ; `
#     Remove-Item get-pip.py -Force; `
#     `
#     Write-Host 'Verifying pip install ...'; `
#     pip --version; `
#     `
#     Write-Host 'Complete.';



# <---- TESTING ONLY: Build Tools ----->

# Copy our Install script.
COPY Install.cmd C:\TEMP\

# Download collect.exe in case of an install failure.
ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe

# Use the latest release channel. For more control, specify the location of an internal layout.
ARG CHANNEL_URL=https://aka.ms/vs/16/release/channel
ADD ${CHANNEL_URL} C:\TEMP\VisualStudio.chman

# Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

RUN ls .

# Install Build Tools excluding workloads and components with known issues.
# RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
RUN C:\TEMP\Install.cmd C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --all `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK
RUN Expand-Archive C:\vslogs.zip vslogs

# Start developer command prompt with any other commands specified.
# ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&


# <---- END TESTING ONLY ----->

COPY docker-entrypoint.cmd /
COPY docker-run.ps1 /
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
ENTRYPOINT C:\\docker-entrypoint.cmd

EXPOSE 5432
# CMD ["powershell", "C:\\docker-start.ps1"]
CMD powershell -Command C:\\docker-run.ps1


