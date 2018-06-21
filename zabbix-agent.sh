#!/bin/bash
#The shell for zabbix-agent
#设置解析
echo "nameserver 114.114.114.114" >> /etc/resolv.conf
#安装网络源，zabbix源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
#刷新缓存
yum makecache
#安装zabbix客户端
yum install zabbix-agent -y
#编辑配置文件，启动
sed -i.ori 's#Server=127.0.0.1#Server=192.168.0.31#' /etc/zabbix/zabbix_agentd.conf
systemctl start  zabbix-agent.service
#添加到开机启动项
chmod a+x /etc/rc.d/rc.local 
echo "systemctl start zabbix-agent.service" >> /etc/rc.d/rc.local 
