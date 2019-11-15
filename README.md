# Dockerized PostgreSQL for Windows (Server 2019)


## Running additional scripts at first run

Any `*.sql` or `*.cmd` files will be run in the appropriate context if placed within the `docker-entrypoint-initdb.d/` folder.

## Quote and Backslash rules in Windows Containers

Command   |   Quotes    | Double Backslash
----------|-------------|------------------
`RUN`     | Yes         | Yes
`RUN`     | No          | No