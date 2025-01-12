#!/bin/bash
source common.sh

PRINT "Setup MYSQL Repps\t"
sudo tee /etc/yum.repos.d/mysql.repo <<EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 >/etc/yum.repos.d/mysql.repo
EOF
STAT_CHECK $?

PRINT "Install MYSQL\t\t"
dnf clean all &>>$LOG && dnf install mysql-community-server -y &>>$LOG
STAT_CHECK $?

PRINT "Start MYSQL Server\t"
systemctl enable mysqld &>>$LOG && systemctl start mysqld &>>$LOG
STAT_CHECK $?

PRINT "Reset MYSQL Root Password"
DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
echo "show databases;" | mysql -uroot -pRoboshop@1 &>>$LOG
if [ $? -ne 0 ]; then
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Roboshop@1';" | mysql --connect-expired-password -uroot -p${DEFAULT_PASSWORD} &>>$LOG
fi
STAT_CHECK $?

PRINT "Uninstall MYSQL Password Policy"
echo SHOw PLUGINS | mysql -uroot -pRoboShop@1 2>>$LOG | grep -i validate_password &>>$LOG
if [ $? -ne 0 ];then
  echo "uninstall plugin validate_password;" | mysql -uroot -pRoboshop@1 &>>$LOG
fi
STAT_CHECK $?

PRINT "Download Schema\t\t"
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>$LOG
STAT_CHECK $?

PRINT "Load Schema\t\t"
cd /tmp && unzip -o mysql.zip &>>$LOG && cd mysql-main && mysql -uroot -pRoboShop@1 <shipping.sql &>>$LOG
STAT_CHECK $?









