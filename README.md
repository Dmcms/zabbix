# zabbix
#install zabbix.tar.gz
#mysql创建密码
mysqladmin -u root password "123456"  
#创建数据库并授权
mysql> create database zabbix;
mysql> grant all on zabbix.* to zabbix@localhost identified by '123456';
mysql> flush privileges;
#解压包
 tar -zxf zabbix-3.4.3.tar.gz -C /usr/local/src/
 cd /usr/local/src/zabbix-3.4.3/
#按顺序依次导入数据库
mysql -uzabbix -p123456 zabbix < database/mysql/schema.sql
mysql -uzabbix -p123456 zabbix < database/mysql/images.sql
mysql -uzabbix -p123456 zabbix < database/mysql/data.sql
#解决依赖
yum install -y net-snmp-devel  
yum install libevent libevent-devel -y
#编译安装mysql
groupadd zabbix
useradd -s /sbin/nologin -g zabbix zabbix
 ./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql=/usr/local/mysql/bin/mysql_config --with-net-snmp --with-libcurl
