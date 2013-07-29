#!/bin/bash
 
# Check that we know what to backup and where
# CONFIG_FILE should look like this
#MY_CNF=/etc/mysql/my.cnf
#SOURCE_DIR=/var/lib/mysql
#BASE_DIR=/media/backup/mysql-dev/myapp
#BACKUP_DIR=${BASE_DIR}/$(date +%Y%m%dT%H%M_%A)
#DATABASE=myapp_production
#TABLES_TO_EXCLUDE='(audits|log_entries|db_files|documents|user_sessions)'
 
if [[ $UID != 0 ]] ; then
echo "This script must be run as root."
exit 255
fi
 
if [[ -z $CONFIG_FILE ]] ; then
echo "Config file not specified."
exit 255
fi
 
. $CONFIG_FILE
 
if [[ -z "${MY_CNF}" ]] ; then
echo "MySQL configuration not specified."
exit 1
fi
 
if [[ -z "$BASE_DIR" ]] ; then
echo "Backup directory not specified."
exit 2
fi
 
if [[ -z "$DATABASE" ]] ; then
echo "Database not specified."
exit 3
fi
 
 
# Make the fresh timestamped dir else xtrabackup WILL crash
mkdir -p ${BACKUP_DIR}/data
 
echo "*******************************************************************"
echo "Write tables... to include"
echo "*******************************************************************"
 
# List tables without exclusions
# Generate tables to INCLUDE
mysql --defaults-file=${MY_CNF} \
-sN information_schema -e "SELECT CONCAT(TABLE_SCHEMA, '.', TABLE_NAME) FROM TABLES WHERE TABLE_SCHEMA='${DATABASE}';" | \
egrep -v "${TABLES_TO_EXCLUDE}" > \
$BACKUP_DIR/tables_to_backup.txt
 
echo "*******************************************************************"
echo "BACKUP UP DATA"
echo "*******************************************************************"
 
# Backup our databases into $BACKUP_DIR, using
# our backup configuration as stored in ${MY_CNF}
#
# NOTE: Directory must not exist, but it's parent must
#innobackupex --defaults-file=${MY_CNF} --no-timestamp --tables-file=$BACKUP_DIR/tables_to_backup.txt $BACKUP_DIR/data
xtrabackup --defaults-file=${MY_CNF} --backup --datadir=${SOURCE_DIR} --target-dir=${BACKUP_DIR}/data --no-timestamp --tables-file=${BACKUP_DIR}/tables_to_backup.txt
 
echo "*******************************************************************"
echo "Process Logs & export "
echo "*******************************************************************"
 
# Process logs & generate meta data
echo "The BACKUP WAS... NOT... PREPARED!"
echo "Preparing."
innobackupex --defaults-file=${MY_CNF} --apply-log --export $BACKUP_DIR/data
 
 
# Enter our backup directory,
# and create a *.ddl.sql file containing only
# schema information, no data.
 
mysqldump --defaults-file=${MY_CNF} \
--no-data --single-transaction \
"$DATABASE" > "$BACKUP_DIR/$DATABASE.ddl.sql"
 
# Add access to the backup for non-root users
chmod 755 ${BACKUP_DIR}/data/${DATABASE}
 
#Symlink 'latest' to the backup to make restore easier
ln -nfs ${BACKUP_DIR} ${BASE_DIR}/latest 
