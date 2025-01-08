#!/bin/bash

source common.sh

PRINT "Installing Nginx"
yum install nginx -y &>>$LOG
STAT_CHECK $?

echo -n -e "Enabling Nginx\t"
systemctl enable nginx &>>$LOG
STAT_CHECK $?

echo -n -e "Starting Nginx\t"
systemctl start nginx &>>$LOG
STAT_CHECK $?