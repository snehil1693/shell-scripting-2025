#!/bin/bash
source common.sh

PRINT "Install Redis Repos"
yum install epel-release  -y &>>$LOG && yum install http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG
STAT_CHECK $?

PRINT "Install Redis\t"
yum-config-manager --enable remi &>>$LOG && yum install redis -y &>>$LOG
STAT_CHECK $?

PRINT "Update Redis Listen Address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
STAT_CHECK $?

PRINT "Start Redis Service"
systemctl enable redis &>>$LOG && systemctl start redis &>>$LOG
STAT_CHECK $?