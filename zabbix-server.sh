#!/bin/bash
#The shell for zabbix-server
#配置解析
echo "nameserver 114.114.114.114" >> /etc/resolv.conf
#安装网络源，zabbix源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
#刷新缓存
yum makecache
#安装zabbix
yum install -y zabbix-server-mysql zabbix-web-mysql
#安装启动mariadb
yum install mariadb-server -y
systemctl start mariadb.service
#创建数据库
mysql -e 'create database zabbix character set utf8 collate utf8_bin;'
mysql -e 'grant all privileges on zabbix.* to zabbix@localhost identified by "zabbix";'
#导入数据库
zcat /usr/share/doc/zabbix-server-mysql-3.0.18/create.sql.gz|mysql -uzabbix -pzabbix zabbix
#配置zabbix-server连接mysql
sed -i.ori '115a DBPassword=zabbix' /etc/zabbix/zabbix_server.conf
#添加时区
sed -i.ori '18a php_value date.timezone  Asia/Shanghai' /etc/httpd/conf.d/zabbix.conf
#解决中文乱码
yum -y install wqy-microhei-fonts
\cp /usr/share/fonts/wqy-microhei/wqy-microhei.ttc /usr/share/fonts/dejavu/DejaVuSans.ttf
#启动服务
systemctl restart zabbix-server
systemctl restart httpd
#添加到开机启动
chkconfig mariadb on
chkconfig httpd on
chkconfig zabbix-server on
#输出信息
echo "浏览器访问 http://`hostname -I|awk '{print $1}'`/zabbix"

