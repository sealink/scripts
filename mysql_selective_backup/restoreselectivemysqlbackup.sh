#!/bin/bash

# Check that we know what to backup and where
# CONFIG_FILE should look like this
#MYSQL_USER=thedbuser
#MYSQL_PW=thepassword
#SOURCE_DATABASE=myappdb
#TARGET_DATABASE=myappdb
#SOURCE_DIR=/media/backup/mysql-dev/myapp/latest
#TARGET_DIR=/var/lib/mysql
#SANDBOX=true

no_mysql() {
  echo "MySQL configuration is bad and wrong. Unable to connect."
  exit 1
}

if [[ -z $CONFIG_FILE ]] ; then
  echo "Config file not specified."
  exit 255
fi

. $CONFIG_FILE


# Require root for system server, but not for sandbox

# If unset or not 'true', SANDBOX is false.
if [[ -z $SANDBOX ]] ; then
  SANDBOX=false
fi
$SANDBOX 2> /dev/null || SANDBOX=false

if [[ $UID != 0 ]] ; then
  if ! $SANDBOX ; then
    echo "Running as normal user requires a sandbox."
    exit 4
  fi
else
  if $SANDBOX ; then
    echo "Running as root with a sandbox is not supported."
    exit 4
  fi
fi


if [[ -z "$SOURCE_DATABASE" ]] ; then
  echo "Database not specified."
  exit 3
fi

if [[ -z "$TARGET_DATABASE" ]] ; then
  echo "Database not specified."
  exit 3
fi


# Execute mysql with this
if $SANDBOX ; then
  MY_SQL="$TARGET_DIR/../my sql"
else
  MY_SQL="mysql -u $MYSQL_USER -p${MYSQL_PW}"
  MYSQL_SYS_USER="mysql"
  MYSQL_SYS_GROUP="mysql"
fi

# Can we connect?
$MY_SQL -e 'SELECT @@version;' > /dev/null 2>&1 || no_mysql

# Create and import database schema (independent?)
echo "Creating schema..."
$MY_SQL -e "DROP DATABASE IF EXISTS $TARGET_DATABASE;"
$MY_SQL -e "CREATE DATABASE $TARGET_DATABASE;"
$MY_SQL $TARGET_DATABASE < $SOURCE_DIR/$SOURCE_DATABASE.ddl.sql
 
# Required for backup
$MY_SQL -e 'SET GLOBAL innodb_import_table_from_xtrabackup=1;'

# Discard tablespace (associated .ibd file on disk)
echo "Importing data..."
cd ${SOURCE_DIR}/data/${SOURCE_DATABASE}

for FILE in *.exp ; do
  TABLE="$(basename "${FILE}" .exp)"
  echo " => importing table ${TABLE}"
  $MY_SQL $TARGET_DATABASE -e "ALTER TABLE $TABLE DISCARD TABLESPACE;"
  cp -f $TABLE.exp "$TARGET_DIR/$TARGET_DATABASE/$TABLE.exp"
  cp -f $TABLE.ibd "$TARGET_DIR/$TARGET_DATABASE/$TABLE.ibd"
  if ! $SANDBOX ; then
    chown $MYSQL_SYS_USER:$MYSQL_SYS_GROUP "$TARGET_DIR/$TARGET_DATABASE/$TABLE.exp"
    chown $MYSQL_SYS_USER:$MYSQL_SYS_GROUP "$TARGET_DIR/$TARGET_DATABASE/$TABLE.ibd"
  fi
  $MY_SQL $TARGET_DATABASE -e "ALTER TABLE $TABLE IMPORT TABLESPACE;" 
done
