# Dockerized PostgreSQL for Windows (Server 2016)


## Running additional scripts at first run

Any `*.sql` or `*.cmd` files will be run in the appropriate context if placed within the `docker-entrypoint-initdb.d/` folder.
