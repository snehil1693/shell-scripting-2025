#!/bin/bash

LOG=/tmp/roboshop.log
rm -rf $LOG

echo -e "Installing Nginx\t\t..."
yum install nginx -y &>>$LOG
if [ $? -eq 0 ]; then
  echo done
else
  echo fail
fi

echo -e "Enabling Nginx"
systemctl enable nginx &>>$LOG

echo -e "Starting Nginx"
systemctl start nginx &>>$LOG