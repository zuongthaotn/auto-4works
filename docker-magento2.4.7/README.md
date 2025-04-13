Nginx: 1.18
Php: 8.3.19-fpm
Mysql: 8.0.41
Redis: 7.2
elasticsearch: 8.16.6
Magento: 2.4.7


--> DOING
## Steps:
1. Create folders:
    - db_data
    - src
    - mysql-dump
    - logs/nginx
2. Copy Magento 2.4.7 project to src/ folder
    - use composer
    - git clone
    - or copy
    - or use scp to download from server.
3. Copy file database to import mysql-dump/ folder and rename it to magento.sql
4. docker-compose build mage247_php --no-cache
5. run docker-compose up -d
6. access mysql and change base_url
update core_config_data set value = 'http://mage247.local:8080/' where path = 'web/unsecure/base_url';
update core_config_data set value = 'http://mage247.local:8080/' where path = 'web/secure/base_url';