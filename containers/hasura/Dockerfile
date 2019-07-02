
FROM microsoft/windowsservercore

LABEL maintainer="eric@hiller.pro"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]



RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri 'https://github.com/commercialhaskell/stack/releases/download/v2.1.1/stack-2.1.1-windows-x86_64.zip' -OutFile 'C:\\stack.zip'; \
    Expand-Archive 'C:\\stack.zip'-Force -DestinationPath /stack