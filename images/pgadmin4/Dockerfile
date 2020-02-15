####
#### Download and prepare PostgreSQL for Windows
####
FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="eric@hiller.pro"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Set the variables for EnterpriseDB
# see https://www.enterprisedb.com/edb-docs
ENV EDB_VER 12.2-1
ENV EDB_REPO https://get.enterprisedb.com/postgresql

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri $('{0}/postgresql-{1}-windows-x64-binaries.zip' -f $env:EDB_REPO,$env:EDB_VER) -OutFile 'C:\\EnterpriseDB.zip'
RUN Expand-Archive 'C:\\EnterpriseDB.zip'-Force -DestinationPath 'C:\\'
RUN Remove-Item -Path 'C:\\EnterpriseDB.zip'

# Install correct Visual C++ Redistributable Package
RUN Write-Host('Visual C++ 2017 Redistributable Package') ; \
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

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v8.1.1568/gvim_8.1.1568_x64.zip' -OutFile 'C:\\vim.zip'
RUN Expand-Archive 'C:\\vim.zip'-Force -DestinationPath /vim

RUN setx /M PATH ( '{0};{1};{2}' -f ( 'C:\\pgsql\\bin', 'C:\\vim\\vim\\vim81', $env:PATH ) )

# COPY docker-entrypoint.cmd /
# COPY docker-run.ps1 /
# COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
# ENTRYPOINT ["C:\\docker-entrypoint.cmd"]








ENV PYTHON_VERSION 3.7.4
ENV PYTHON_RELEASE 3.7.4

RUN $url = ('https://www.python.org/ftp/python/{0}/python-{1}-amd64.exe' -f $env:PYTHON_RELEASE, $env:PYTHON_VERSION); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'python.exe'; \
	\
	Write-Host 'Installing ...'; \
# https://docs.python.org/3.5/using/windows.html#installing-without-ui
	Start-Process python.exe -Wait \
		-ArgumentList @( \
			'/quiet', \
			'InstallAllUsers=1', \
			'TargetDir=C:\Python', \
			'PrependPath=1', \
			'Shortcuts=0', \
			'Include_doc=0', \
			'Include_pip=0', \
			'Include_test=0' \
		); \
	\
# the installer updated PATH, so we should refresh our local value
	$env:PATH = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::Machine); \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  python --version'; python --version; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item python.exe -Force; \
	\
	Write-Host 'Complete.';

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 19.3.1

RUN Write-Host ('Installing pip=={0} ...' -f $env:PYTHON_PIP_VERSION); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile 'get-pip.py'; \
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		('pip=={0}' -f $env:PYTHON_PIP_VERSION) \
	; \
	Remove-Item get-pip.py -Force; \
	\
	Write-Host 'Verifying pip install ...'; \
	pip --version; \
	\
	Write-Host 'Complete.';

# This is the email address used when setting up the initial administrator account to login to pgAdmin. This variable is required and must be set at launch time.
ENV PGADMIN_DEFAULT_EMAIL ""

# This is the password used when setting up the initial administrator account to login to pgAdmin. This variable is required and must be set at launch time.
ENV PGADMIN_DEFAULT_PASSWORD postgres

# Set to True or False
ENV PGADMIN_ENABLE_TLS False

ENV PGADMIN_LISTEN_PORT 80

ENV PGADMIN_LISTEN_ADDRESS 0.0.0.0

# Adjust the number of threads the server uses to handle incoming requests. This should typically be left as-is, except in highly loaded systems where it may be increased.
ENV THREADS 25

ENV HOSTNAME pgadmin4.local


RUN Write-Information 'Install apache web server...' ; \
	$ErrorActionPreference = 'Stop'; \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Method Get -Uri https://home.apache.org/~steffenal/VC14/binaries/httpd-2.4.41-win64-VC14.zip -OutFile c:\apache.zip ; \
	Expand-Archive -Path c:\apache.zip -DestinationPath c:\ ; \
	Remove-Item c:\apache.zip -Force

RUN Write-Information 'Install VC Redist for apache web server...' ; \
	$ErrorActionPreference = 'Stop'; \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Method Get -Uri 'https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe' -OutFile c:\vc_redist.x64.exe ; \
	start-Process c:\vc_redist.x64.exe -ArgumentList '/quiet' -Wait ; \
	Remove-Item c:\vc_redist.x64.exe -Force


RUN Invoke-WebRequest 'http://download.microsoft.com/download/5/f/7/5f7acaeb-8363-451f-9425-68a90f98b238/visualcppbuildtools_full.exe' -OutFile 'visualcppbuildtools_full.exe' -UseBasicParsing ; \
    Start-Process .\visualcppbuildtools_full.exe -ArgumentList '/NoRestart /S' -Wait ; \
    Remove-Item visualcppbuildtools_full.exe

RUN Write-Host 'Configuring environment'; \
	pushd 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC' ; \
	cmd /c 'vcvarsall.bat amd64&set' | foreach { \
    if ($_ -match '=') { \
      $v = $_.split('='); \
      [Environment]::SetEnvironmentVariable($v[0], $v[1], [EnvironmentVariableTarget]::Machine); \
    } \
  } ; \
	popd

WORKDIR /code

# RUN setx /M PATH ( '{0};{1};{2};{3};{4};{5}' -f ( 'C:\\Python', 'C:\\Python\\include', 'C:\\pgsql\pgAdmin 4\\venv\\Scripts', 'C:\\pgsql\pgAdmin 4\\venv', 'C:\\Apache24\\bin', $env:PATH ) )
RUN setx /M PATH ( '{0};{1};{2};{3}' -f ( 'C:\\pgsql\pgAdmin 4\\venv\\Scripts', 'C:\\pgsql\pgAdmin 4\\venv', 'C:\\Apache24\\bin', $env:PATH ) )
# RUN setx /M PYTHONPATH ( '{0};{1}' -f ( 'C:\\pgsql\\pgAdmin 4\\venv\\Lib\\site-packages', ( python -c 'import sys; print(chr(59).join(x for x in sys.path if x))') ) )


# RUN pip install mod-wsgi ; \
#     ls C:\Python; \
#     ls C:\Python\Scripts; \
#     Add-Content -Path C:\Apache24\conf\httpd.conf -Value (C:\Python\Scripts\mod_wsgi-express module-config) ;
    
# RUN pip install https://download.lfd.uci.edu/pythonlibs/t4jqbe6o/mod_wsgi-4.6.7+ap24vc15-cp37-cp37m-win_amd64.whl ; \
#     Add-Content -Path C:\Apache24\conf\httpd.conf -Value (mod_wsgi-express module-config) ;
    

WORKDIR /Apache24/bin

ENV PGADMIN_CONFIG_PATH C:/pgsql/pgAdmin 4/web/config_local.py
ENV PGADMIN_DATA_DIR C:/data/pgadmin4
ENV PGADMIN_SERVER_JSON_FILE C:/data/pgadmin4/servers.json

# RUN touch $env:PGADMIN_CONFIG_PATH

# RUN mkdir $env:PGADMIN_DATA_DIR

# RUN pip install flask flask_login flask_babelex virtualenv virtualenvwrapper psycopg2 Flask-Mail


COPY start-pgadmin4.ps1 /

EXPOSE $PGADMIN_LISTEN_PORT
# CMD ["powershell", "C:\\docker-start.ps1"]
CMD [ "powershell" , "C:\\start-pgadmin4.ps1"]


HEALTHCHECK --start-period=30s --interval=30s --retries=5 \
    CMD powershell -command \
    try { \
    $response = iwr -useb http://localhost; \
    if ($response.StatusCode -eq 200) { return 0 } \
    else {return 1}; \
    } catch { return 1 }