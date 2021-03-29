""" sample config & documenation.

https://www.pgadmin.org/docs/pgadmin4/latest/config_py.html
"""

import os
from pgadmin.utils import env, fs_short_path
# from typing import List


SERVER_MODE = True
X_FRAME_OPTIONS = ""
## the below CAN NOT BE SET TO AN EMPTY LIST
# WTF_CSRF_HEADERS: List[str] = []  # ['X-pgA-CSRFToken']
UPGRADE_CHECK_ENABLED = str.lower(env('PGADMIN_CONFIG_UPGRADE_CHECK_ENABLED')) == "true"
USER_INACTIVITY_TIMEOUT = 0
SESSION_EXPIRATION_TIME = 365

DEFAULT_SERVER = '127.0.0.1'
DEFAULT_SERVER_PORT = int(env('PGADMIN_LISTEN_PORT'))  # Note: this has no effect since I am hosting it as a WSGI application

UPGRADE_CHECK_KEY = 'pgadmin4'


###### PATHS ######

SQLITE_PATH             = os.path.realpath(env('PGADMIN_SQLITE_PATH'))
SESSION_DB_PATH         = os.path.realpath( os.path.join(fs_short_path(env('PGADMIN_DATA_DIR')), "sessions"))
STORAGE_DIR             = os.path.realpath( os.path.join(fs_short_path(env('PGADMIN_DATA_DIR')), "storage"))
DEFAULT_BINARY_PATHS    = {"pg": "C:\\pgsql\\bin", "ppas": "", "gpdb": ""}
DATA_DIR                = os.path.realpath( fs_short_path(env('PGADMIN_DATA_DIR') ) )

###### Basic #######

APP_NAME = env('PGADMIN_CONFIG_APP_NAME')
loginBanner = env('PGADMIN_CONFIG_LOGIN_BANNER')
if ( loginBanner is not None ):
    LOGIN_BANNER = loginBanner

###### logging ######
# https://www.pgadmin.org/faq/#8

# Application log level - one of:
#   CRITICAL 50
#   ERROR    40
#   WARNING  30
#   SQL      25
#   INFO     20
#   DEBUG    10
#   NOTSET    0

DEBUG = str.lower(env('PGADMIN_CONFIG_DEBUG')) == "true"
CONSOLE_LOG_LEVEL = int(env('PGADMIN_CONFIG_CONSOLE_LOG_LEVEL'))
FILE_LOG_LEVEL = int(env('PGADMIN_CONFIG_FILE_LOG_LEVEL'))


AUTHENTICATION_SOURCES = [
    x.strip() for x in env('PGADMIN_CONFIG_AUTHENTICATION_SOURCES').split(',')
]

# Log format.
CONSOLE_LOG_FORMAT = '%(asctime)s: %(levelname)s\t%(name)s:\t%(message)s'
FILE_LOG_FORMAT = '%(asctime)s: %(levelname)s\t%(name)s:\t%(message)s'

# Log file name
LOG_FILE = os.path.realpath(
    os.path.join(fs_short_path(env('PGADMIN_DATA_DIR')), "pgadmin4.log"))


################################################################################
##################################### LDAP #####################################
################################################################################

LDAP_AUTO_CREATE_USER = str.lower(env('PGADMIN_CONFIG_LDAP_AUTO_CREATE_USER')) == "true"
LDAP_BIND_USER = env('PGADMIN_CONFIG_LDAP_BIND_USER')
LDAP_BIND_PASSWORD = env('PGADMIN_CONFIG_LDAP_BIND_PASSWORD')
LDAP_SERVER_URI = env('PGADMIN_CONFIG_LDAP_SERVER_URI')
LDAP_USERNAME_ATTRIBUTE = env('PGADMIN_CONFIG_LDAP_USERNAME_ATTRIBUTE')
LDAP_SEARCH_BASE_DN = env('PGADMIN_CONFIG_LDAP_SEARCH_BASE_DN')
LDAP_SEARCH_FILTER = env('PGADMIN_CONFIG_LDAP_SEARCH_FILTER')
LDAP_SEARCH_SCOPE = env('PGADMIN_CONFIG_LDAP_SEARCH_SCOPE')

print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LOADING pgadmin config local")
print(f"""

SQLITE_PATH             :  {SQLITE_PATH}
SESSION_DB_PATH         :  {SESSION_DB_PATH}
STORAGE_DIR             :  {STORAGE_DIR}
DEFAULT_BINARY_PATHS    :  {DEFAULT_BINARY_PATHS}
DATA_DIR                :  {DATA_DIR}
AUTHENTICATION_SOURCES  :  {AUTHENTICATION_SOURCES}
DEBUG                   :  {DEBUG}
CONSOLE_LOG_LEVEL       :  {CONSOLE_LOG_LEVEL}
FILE_LOG_LEVEL          :  {FILE_LOG_LEVEL}

LDAP_AUTO_CREATE_USER   :  {LDAP_AUTO_CREATE_USER}
LDAP_BIND_USER          :  {LDAP_BIND_USER}
LDAP_BIND_PASSWORD      :  {LDAP_BIND_PASSWORD}
LDAP_SERVER_URI         :  {LDAP_SERVER_URI}
LDAP_USERNAME_ATTRIBUTE :  {LDAP_USERNAME_ATTRIBUTE}
LDAP_SEARCH_BASE_DN     :  {LDAP_SEARCH_BASE_DN}
LDAP_SEARCH_FILTER      :  {LDAP_SEARCH_FILTER}
LDAP_SEARCH_SCOPE       :  {LDAP_SEARCH_SCOPE}

""")

###### OPTIONS ######

MASTER_PASSWORD_REQUIRED = False

# Queries stored for callback in Query History of Query Tool
MAX_QUERY_HIST_STORED = 1000
