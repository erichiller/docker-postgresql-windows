# docker container rm -f elasticsearch ; docker image build .\elasticsearch\ -t ehiller/elasticsearch:latest -t ehiller/elasticsearch-windows:latest -t ehiller/elasticsearch-windows:7.2.0; docker run -p 9200:9200 -p 9300:9300 -e "discovery_type=single-node" -v /s/virtual_machines/containers/elasticsearch:/data --name elasticsearch ehiller/elasticsearch:latest


$NAME="pgadmin"
$DOCKER_USER="ehiller"
$EDB_VER = "13.2-1"
# Get the SHA from the downloads page



Push-Location $PSScriptRoot

# docker container rm -f $NAME

docker image build $PSScriptRoot `
    -t $DOCKER_USER/${NAME}:latest `
    -t $DOCKER_USER/${NAME}-windows:latest `
    -t $DOCKER_USER/${NAME}-windows:${EDB_VER} `
    -t $DOCKER_USER/${NAME}:$(Get-Date -format "yyMMdd_HHmmss" ) `
    --build-arg EDB_VER=$EDB_VER `
    # --no-cache `
    ;

$errorCode = $?;
Write-Host "Docker Success? $errorCode";

Pop-Location

if ( $errorCode -eq $False ){
    throw 'Docker Failed to run'
}



# TESTING:
# & {
#     docker rm -f pgadmin-test; 
#     .\images\pgadmin\build.ps1 ;
#     if ( $? ) { 
#         Write-Host "continuing" ; 
#         docker run --rm -h pgadmin-test --name pgadmin-test --env-file .\env\pgadmin.env --network 'Mellanox ConnectX-3 Pro Ethernet Adapter #2 - Virtual Switch' --mac-address "4E:00:00:00:00:29" ehiller/pgadmin:latest ;
#     }
# }



# For interactive:
# docker run -it --network "Mellanox ConnectX-3 Pro Ethernet Adapter #2 - Virtual Switch" --mac-address="4E:00:00:00:03:01" --hostname="telegraf" --name ${NAME} ehiller/${NAME}:latest powershell.exe

# 
# docker run --network "Mellanox ConnectX-3 Pro Ethernet Adapter #2 - Virtual Switch" --mac-address="4E:00:00:00:03:01" --hostname="telegraf" --name ${NAME} ehiller/${NAME}:latest
# docker run --name $NAME ehiller/$NAME:latest
# docker run -p 3000:3000 -v s:/virtual_machines/containers/grafana:c:/data --name $NAME ehiller/$NAME:latest


# testing container
# docker run -h pgadmin-test --name pgadmin-text --env-file .\env\pgadmin.env ehiller/pgadmin:latest