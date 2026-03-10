#!/bin/bash
# ================================================================== #
# Backup a website script
# ================================================================== #
# Copyright (c) 2019 Zuongthao
# This script is a private licensed version
# ================================================================== #
#
#
#
# ================================================================== #
#          Define system specific details in this section            #
# ================================================================== #
#
#	Tao thu muc backup
#	Backup database
#	Copy cac thu muc code
#	Zip thu backup
# ================================================================== #
# 
echo "------------------------------------------------------------------"
#
#
CODEFOLDER='httpdocs'
BACKUPFOLDER='magnus_httpdocs_101019'
HOSTNAME='localhost'
MYSQLUSER='surfladen01'
MYSQLPW='Tuyen@9x'
DB='admin_surfladen01'
# ================================================================== #
#
# ----Tao thu muc backup-----#
if [ ! -d "$SITEDIR" ]; then
  mkdir $BACKUPFOLDER
fi
#
echo "...Start copying magento source code"
cp -ar $CODEFOLDER"/"* $BACKUPFOLDER
echo "...Done copying magento source code"
#
echo "...Start cleaning magento generated files in backup folder"
rm -rf $BACKUPFOLDER"/generated/"*
rm -rf $BACKUPFOLDER"/pub/static/"*
rm -rf $BACKUPFOLDER"/pub/media/catalog/product/cache/"*
rm -rf $BACKUPFOLDER"/var/cache/"*
rm -rf $BACKUPFOLDER"/var/log/"*
rm -rf $BACKUPFOLDER"/var/page_cache/"*
rm -rf $BACKUPFOLDER"/var/tmp/"*
rm -rf $BACKUPFOLDER"/var/view_preprocessed/"*
echo "...Done cleaning magento generated files in backup folder"
#
cd $BACKUPFOLDER
#
echo "...Start backup mysql database"
if ( mysqldump --user="$MYSQLUSER" --password="$MYSQLPW" $DB > $DB"_mbackup.sql" ) ; then
echo "...Done backup database"
fi
#
cd ..
#
echo "Starting compressing folder"
zip -r $BACKUPFOLDER".zip" $BACKUPFOLDER"/"*
echo "--------------------Everything is Done!!!!---------------------------"

