#!/bin/bash

LOG=/tmp/roboshop.log
rm -rf $LOG

echo -n -e "Installing Nginx\t\t..."
yum install nginx -y &>>$LOG


echo -n -e "Enabling Nginx\t\t\t..."
systemctl enable nginx &>>$LOG
if [ $? -eq 0 ]; then
  echo -e "\e[32m done\e[0m"
else
  echo -e "\e[31m fail\e[0m"
  exit 1
fi

echo -n -e "Starting Nginx\t\t\t..."
systemctl start nginx &>>$LOG
if [ $? -eq 0 ]; then
  echo -e "\e[32m done\e[0m"
else
  echo -e "\e[31m fail\e[0m"
  exit 1
fi