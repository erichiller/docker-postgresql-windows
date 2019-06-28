# Volumes on Windows

[Volumes (general Docker docs)](https://docs.docker.com/storage/volumes/)

[Volumes (Windows specific, Microsoft docs)](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-storage)

[Volumes in _docker-compose_](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)

## Workarounds



One often discussed method to get volumes working well with postgres and docker-compose is to create an external volume first, as seen in the [docker forums](https://forums.docker.com/t/trying-to-get-postgres-to-work-on-persistent-windows-mount-two-issues/12456/5) and [in the docker github issues](https://github.com/docker/for-win/issues/445)

