#!/bin/bash
source common.sh

PRINT "Install Nodejs\t\t"
yum install nodejs make gcc-c++ -y &>>$LOG
STAT_CHECK $?

PRINT "Add Roboshop Applicaion User"
id roboshop &>>$LOG
if [ $? -ne 0 ];then
  useradd roboshop &>>$LOG
fi
STAT_CHECK $?

PRINT "Download Applicaion Code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>$LOG
STAT_CHECK $?

PRINT "Extract Downloaded Code\t"
cd /home/roboshop && unzip -o /tmp/catalogue.zip &>>$LOG && rm -rf catalogue && mv catalogue-main catalogue
STAT_CHECK $?

PRINT "Install Nodejs Dependencies"
cd /home/roboshop/catalogue && npm install --unsafe perm &>>$LOG
STAT_CHECK $?

PRINT "FIX Applicaion Permissions"
chown roboshop:roboshop /home/roboshop -R &>>$LOG
STAT_CHECK $?

PRINT "Setup SystemD file\t"
sed -i -e "s/MONGO_DNSNAME/monogdb.roboshop.internal/" /home/roboshop/catalogue/systemd.service &&
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
STAT_CHECK $?

PRINT "Start Catalogue Service\t"
systemctl daemon-reload &>>$LOG && systemctl start catalogue &>>$LOG && systemctl enable catalogue &>>$LOG