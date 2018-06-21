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
#编译安装zabbix
groupadd zabbix
useradd -s /sbin/nologin -g zabbix zabbix
 ./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql=/usr/local/mysql/bin/mysql_config --with-net-snmp --with-libcurl
make install
#编辑zabbix-server服务端配置文件
vim /usr/local/zabbix/etc/zabbix_server.conf
   DBHost=localhost
   DBName=zabbix           #数据库用户
   DBUser=zabbix           #默认是root,授权用户是zabbix
   DBPassword=123456
#编辑zabbix-agent客户端配置文件(此处监控本身，即服务端和客户端在同一机器)
vim /usr/local/zabbix/etc/zabbix_agentd.conf
   Server=127.0.0.1          #允许此IP获取数据
   ServerActive=127.0.0.1    #客户端提交数据给此IP
   Hostname=Zabbix server    #主机名
   UnsafeUserParameters=1    #支持自定义脚本
 #启动服务
 /usr/local/zabbix/sbin/zabbix_server          #此方法关闭只能用kill
 #或通过启动脚本启动zabbix
 cd /usr/local/src/zabbix-3.4.3/misc/init.d/
 cp fedora/core/* /etc/rc.d/init.d/
 vim /etc/init.d/zabbix_server
    BASEDIR=/usr/local/zabbix
 vim /etc/init.d/zabbix_agentd
    BASEDIR=/usr/local/zabbix
 #启动服务
 /etc/init.d/zabbix_agentd start
#添加到开机启动项
chkconfig zabbix_server on
chkconfig zabbix_agentd on
#编辑php控制页面，Nginx加载zabbix页面
cp -r /usr/local/src/zabbix-3.4.3/frontends/php/* /usr/local/nginx/html/
vim /usr/local/nginx/conf/nginx.conf
   location / {
   root html;
   index index.php index.html index.htm;   #添加index.php
   }
#重启nginx和php-fpm服务
/usr/local/nginx/sbin/nginx -s reload
/etc/init.d/zabbix_server restart
/etc/init.d/php-fpm restart
#输出信息
echo "浏览器访问 http://`hostname -I|awk '{print $1}'`/"

