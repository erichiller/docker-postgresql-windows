
-- Create additional users (must be made in postgres before they will be looked up in LDAP for their password)
CREATE USER eric SUPERUSER;

CREATE USER hass;
CREATE DATABASE hass;
ALTER ROLE hass WITH login;
GRANT ALL ON DATABASE hass TO hass;

CREATE USER grafana;
CREATE DATABASE grafana;
ALTER ROLE grafana WITH login;
GRANT ALL ON DATABASE grafana TO grafana;

