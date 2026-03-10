#!/bin/bash
# ================================================================== #
# Ubuntu web server build shell script
# ================================================================== #
# Copyright (c)2017-2019 Zuongthao
# This script is a private licensed version
# ================================================================== #
#
#
#
# ================================================================== #
#          Define system specific details in this section            #
# ================================================================== #
#
#	Setup moi truong
#	Cai dat nginx,mysql server-client,...
#	Tao cac thu muc /var/www/html/$DEV   $DEV thi nhu nao cung dc
#	Mysql tao user name magento pass magento123
#	Tao thu muc /var/www/_magento_source/m2/ de chua code magento
# 	Code magento dc copy vao day ve de theo dang/cu phap mage_ce_225
#	Tao file /var/www/html/index.html
# ================================================================== #
# 
echo "------------------------------------------------------------------"
#
#
HOSTNAME='localhost'
MYSQLUSER='magento'
MYSQLPW='magento123'
MAGENTOVERSION='ce_232'
DOMAIN='ce232.local'
DB='ce232_local'
NGINXUSER='zuongthao'
# ================================================================== #
SITEDIR='/var/www/html/'$DOMAIN
MAGENTOSOURCEDIR='/var/www/_magento_source/m2/'$MAGENTOVERSION
# ================================================================== #
# ----Create database-----#
QUERY="DROP DATABASE IF EXISTS $DB;CREATE DATABASE $DB;"
#QUERY="CREATE DATABASE $DB;"
if ( mysql --user="$MYSQLUSER" --password="$MYSQLPW" -f -e "$QUERY" ) ; then
echo "...Done creating database $DB"
fi
#
echo "...Start copying magento source code"
if [ ! -d "$SITEDIR" ]; then
  mkdir $SITEDIR
fi
cp -a $MAGENTOSOURCEDIR/* $SITEDIR
echo "...Done copying magento source code"
echo "...Adding Nginx configuration"
#
if [ -f "/etc/nginx/sites-enabled/$DOMAIN.conf" ]; then
    rm -rf /etc/nginx/sites-enabled/$DOMAIN.conf
fi
#
echo 'server {

     listen 80;
     server_name '$DOMAIN';
     set $MAGE_ROOT '$SITEDIR";
     include $SITEDIR/nginx.conf.sample;
 }" >> /etc/nginx/sites-enabled/$DOMAIN.conf
#
echo "...Done Nginx configuration"
#
service  nginx restart
#
echo "...Setting up magento website"
cd $SITEDIR
#
php7.2 bin/magento setup:install --base-url="http://$DOMAIN/" --db-host="$HOSTNAME" --db-name="$DB" --db-user="$MYSQLUSER" --db-password="$MYSQLPW" --admin-firstname="admin" --admin-lastname="admin" --admin-email="admin@localhost.com" --admin-user="admin" --admin-password="admin123" --language="en_US" --currency="USD" --timezone="America/Chicago" --use-rewrites="1" --backend-frontname="admin"
#
php7.2 bin/magento deploy:mode:set developer
#
echo "...Adding hosts configuration"
#
echo '127.0.0.1       '$DOMAIN  >> /etc/hosts
#
echo "...Done Nginx configuration"
#
chown -R $NGINXUSER:$NGINXUSER $SITEDIR
chmod -R 777 var/ pub/ generated/
#
echo "--------------------Everything is Done!!!!---------------------------"
