
```
$ docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer



$ docker run -d -p 9000:9000 --name portainer --restart always -v \\.\pipe\docker_engine:\\.\pipe\docker_engine -v S:\virtual_machines\containers\portainer:C:\data portainer/portainer




```


$test = Get-Content C:\sql\pg_hba.conf
$output = $test[0..($test.count - 1)]



```
PS C:\postgresql\pgsql\bin> .\pg_config.exe
BINDIR = C:/postgresql/pgsql/bin
DOCDIR = C:/postgresql/pgsql/doc
HTMLDIR = C:/postgresql/pgsql/doc
INCLUDEDIR = C:/postgresql/pgsql/include
PKGINCLUDEDIR = C:/postgresql/pgsql/include
INCLUDEDIR-SERVER = C:/postgresql/pgsql/include/server
LIBDIR = C:/postgresql/pgsql/lib
PKGLIBDIR = C:/postgresql/pgsql/lib
LOCALEDIR = C:/postgresql/pgsql/share/locale
MANDIR = C:/postgresql/pgsql/man
SHAREDIR = C:/postgresql/pgsql/share
SYSCONFDIR = C:/postgresql/pgsql/etc
PGXS = C:/postgresql/pgsql/lib/pgxs/src/makefiles/pgxs.mk
CONFIGURE = --enable-thread-safety --enable-nls --with-ldap --with-openssl --with-ossp-uuid --with-libxml --with-libxslt --with-icu --with-tcl --with-perl --with-python
CC = not recorded
CPPFLAGS = not recorded
CFLAGS = not recorded
CFLAGS_SL = not recorded
LDFLAGS = not recorded
LDFLAGS_EX = not recorded
LDFLAGS_SL = not recorded
LIBS = not recorded
VERSION = PostgreSQL 11.3
```

```
ldapsearch -D "cn=postgres" -w RrF1kj4cNjxwnJ -p 389 -h deepthought.hiller.pro -b "cn=Users,dc=hiller,dc=pro" -s sub "(sAMAccountName=*)"
ldapsearch -D "postgres@hiller.pro" -w RrF1kj4cNjxwnJ -p 389 -h deepthought.hiller.pro -b "cn=Users,dc=hiller,dc=pro" "sAMAccountName=postgres"










add-content (join-path $sqldata "pg_hba.conf") "host all all 0.0.0.0/0 ldap ldapserver=deepthought.hiller.pro ldapbasedn=CN=Users,DC=hiller,DC=pro ldapbinddn=cn=postgres@hiller.pro ldapbindpasswd=$env:POSTGRES_PASSWORD ldapsearchattribute=sAMAccountName"




```