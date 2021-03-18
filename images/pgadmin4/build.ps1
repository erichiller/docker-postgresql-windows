# docker container rm -f elasticsearch ; docker image build .\elasticsearch\ -t ehiller/elasticsearch:latest -t ehiller/elasticsearch-windows:latest -t ehiller/elasticsearch-windows:7.2.0; docker run -p 9200:9200 -p 9300:9300 -e "discovery_type=single-node" -v /s/virtual_machines/containers/elasticsearch:/data --name elasticsearch ehiller/elasticsearch:latest


$NAME="pgadmin"
$EDB_VER = "13.2-1"
# Get the SHA from the downloads page



Push-Location $PSScriptRoot

# docker container rm -f $NAME

docker image build $PSScriptRoot `
    -t ehiller/${NAME}:latest `
    -t ehiller/$NAME-windows:latest `
    -t ehiller/${NAME}-windows:${EDB_VER} `
    --build-arg EDB_VER=$EDB_VER `
    # --no-cache `
    ;


Pop-Location

# For interactive:
# docker run -it --network "Mellanox ConnectX-3 Pro Ethernet Adapter #2 - Virtual Switch" --mac-address="4E:00:00:00:03:01" --hostname="telegraf" --name ${NAME} ehiller/${NAME}:latest powershell.exe

# 
# docker run --network "Mellanox ConnectX-3 Pro Ethernet Adapter #2 - Virtual Switch" --mac-address="4E:00:00:00:03:01" --hostname="telegraf" --name ${NAME} ehiller/${NAME}:latest
# docker run --name $NAME ehiller/$NAME:latest
# docker run -p 3000:3000 -v s:/virtual_machines/containers/grafana:c:/data --name $NAME ehiller/$NAME:latest
