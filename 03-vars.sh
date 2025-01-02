#!/usr/bin/bash

A=10
echo A = $A

#Commands Subs
No_of_users=$(who | wc -l)
echo Number of Users = $No_of_users

#we are giving any random date
# shellcheck disable=SC1068
DATE="02-01-2025"
echo Welcome, Today date is $DATE