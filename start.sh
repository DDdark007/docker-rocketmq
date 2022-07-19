#!/bin/bash
# 添加虚拟网卡
cat << EOF >> /etc/yum.repos.d/nux-misc.repo
[nux-misc]
name=Nux Misc
baseurl=http://li.nux.ro/download/nux/misc/el7/x86_64/
enabled=0
gpgcheck=1
gpgkey=http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
EOF
# 安装命令
yum --enablerepo=nux-misc install tunctl -y
# 添加网卡 tap0 是虚拟网卡名字
tunctl -t tap0 -u root
ifconfig tap0 192.168.1.20 netmask 255.255.255.0 promisc
# 创建目录
mkdir -p ./broker/{conf,logs,store}
mkdir -p ./namesrv/{logs,store}
# 设置目录权限
chmor chmod -R 777 ./broker/logs
chmor chmod -R 777 ./broker/store
chmor chmod -R 777 ./namesrv/logs
chmor chmod -R 777 ./namesrv/store
# 修改配置文件
Ip=$(ip a | grep tap0 | grep inet | awk '{print $2}' | awk -F '/' '{print $1}')
Ip2=$Ip":9876"
cat << EOF >> ./broker/conf/broker.conf
brokerIP1=$Ip
namesrvAddr=$Ip2
EOF
broker启动默认会取第一个网卡的IP作为监听IP，一般为内网IP。
# 启动
docker-compose up -d
# 查看
docker ps |grep rocketmq
