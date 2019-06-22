Create additional users (must be made in postgres before they will be looked up in LDAP for their password)


```sql
CREATE USER eric;
ALTER USER eric SUPERUSER;
```