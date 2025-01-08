#!/bin/bash

source common.sh

PRINT "Installing Nginx"
yum install nginx -y &>>$LOG
STAT_CHECK $?

PRINT "Enabling Nginx\t"
systemctl enable nginx &>>$LOG
STAT_CHECK $?

PRINT "Starting Nginx\t"
systemctl start nginx &>>$LOG
STAT_CHECK $?