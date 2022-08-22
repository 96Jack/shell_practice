#!/bin/bash
# -*- encoding: utf-8 -*-
'''
file       :1.sh
Description: 服务器系统配置初始化
Date       :2022/08/22 10:10:25
Author     :Xu xxcro
version    :shell 
'''

# 1. 设置时区并同步时间
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
if ! crontab -l | grep crontab &>/dev/null ; then
    (echo "* 1 * * * ntpdate time.windows.com &>/dev/null"; crontab -l) | crontab
fi 

# 2. 禁用selinux
#   替换SELINUX=permissive 为disabled
sed -i "/SELINUX/{s/permissive/disabled/}"  /etc/selinux/config

# 3. 关闭防火墙(centos)
if egrep "7.[0-9]" /etc/redhat-release >&/dev/null; then 
    systemctl stop firewalld
    systemctl disable firewalld
elif egre "6.[0-9]" /etc/redhat-release >&/dev/null; then
    service iptable stop 
    chkconfig iptables off
fi

# 4. 历史命令显示操作时间和用户
if ! grep HISTIMEFORMAT /etc/bash.bashrc; then 
    echo 'export HISTIMEFORMAT "%F %T `whoami`"' >> /etc/bash.bashrc
fi

# 5. 设置ssh超时时间（centos）
if ! grep "TMOUT=600" /etc/profile &>/dev/null ; then
    echo "export TMOUT=600" >> /etc/profile 
fi

# 6. 禁止root远程登录
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config

# 7. 禁止定时任务发送邮件(crontab 若为重定向为空 &>/dev/null，定时任务的输出将会发邮件给用户，存放在/var/mail 下)
sed -i 's/^MAILTO=root/MAILTO=""/' /etc/crontab

# 8. 设置最大打开文件数
if ! grep "* soft nofile 65535"  /etc/secturity/limits.conf &>/dev/null ; then 
cat >> /etc/security/limits.conf  << EOF
    * soft nofile 65535
    * hard nofile 65535
EOF
fi

# 9. 系统内核优化(centos)
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 20480  # timeout
net.ipv4.tcp_max_syn_backlog = 20480 # syn的最大长度
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_fin_timeout = 20    # 缩短fin时间
EOF

# 10. 减少SWAP的使用 : 交换分区在磁盘上的空间，比物理内存要慢很多，尽量不使用
echo "0" > /proc/sys/vm/swappiness

# 安装系统性能分析工具
apt-get install tree vim -y 








