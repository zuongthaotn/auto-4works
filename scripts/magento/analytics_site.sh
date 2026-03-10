#!/bin/bash
# ================================================================== #
# Ananytics a Magento 2 website script
# Version 1.0
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
#	Get ubuntu version
#	List all services running
#	Copy cac thu muc code
#	Zip thu backup
# ================================================================== #
# How to run
# sudo bash analytics_site.sh > report.txt
# ================================================================== #
MAGENTOFOLDER='/var/www/html/mrpets.local'
MAGENTOLOGFOLDER=$MAGENTOFOLDER'/var/log'
SYSTEMLOG=$MAGENTOLOGFOLDER'/system.log'
EXCEPTIONLOG=$MAGENTOLOGFOLDER'/exception.log'
SERVERLOGFOLDER='/var/log'
NGINXLOGFOLDER=$SERVERLOGFOLDER'/nginx'
APACHELOGFOLDER=$SERVERLOGFOLDER'/apache2'
MYSQLLOGFOLDER=$SERVERLOGFOLDER'/mysql'
# ================================================================== #
echo "----Ubuntu version--------------------------------------------------------------"
lsb_release -a
echo "----All running services--------------------------------------------------------"
service --status-all
#echo "----CPU info--------------------------------------------------------------------"
echo "----RAM info--------------------------------------------------------------------"
cat /proc/meminfo
echo "----RAM free--------------------------------------------------------------------"
free
echo "----PHP version-----------------------------------------------------------------"
php -v
echo "----Mysql version---------------------------------------------------------------"
mysql --version
echo "------------------------------MAGENTO-------------------------------------------"
cd $MAGENTOFOLDER
echo "----Module status---------------------------------------------------------------"
php bin/magento module:status
echo "----Cache status-----------------------------------------------------------------"
php bin/magento cache:status
echo "----Deploy mode-----------------------------------------------------------------"
php bin/magento deploy:mode:show
#
if [ ! -f "$SYSTEMLOG" ]; then
  echo "----Magento system log---------------------------------------------------------"
  tail $SYSTEMLOG
fi
#
if [ ! -f "$EXCEPTIONLOG" ]; then
  echo "----Magento exception log-------------------------------------------------------"
  tail $EXCEPTIONLOG
fi
#
echo "------------------------------SERVER-LOG-----------------------------------------"
cd $SERVERLOGFOLDER
ls -lp --sort=size | grep -v /
#
if [ ! -d "$NGINXLOGFOLDER" ]; then
  echo "----Nginx log list---------------------------------------------------------------"
  cd $SERVERLOGFOLDER
  ls -lp --sort=size | grep -v /
fi
#
if [ ! -d "$MYSQLLOGFOLDER" ]; then
  echo "----Mysql log list---------------------------------------------------------------"
  cd $MYSQLLOGFOLDER
  ls -lp --sort=size | grep -v /
fi
#
if [ ! -d "$APACHELOGFOLDER" ]; then
  echo "----Apache2 log list--------------------------------------------------------------"
  cd $APACHELOGFOLDER
  ls -lp --sort=size | grep -v /
fi