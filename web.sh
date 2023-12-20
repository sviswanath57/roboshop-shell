#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "ERROR:: $2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf install nginx -y >> $LOGFILE
VALIDATE $? "Installing nginx" 

systemctl enable nginx

systemctl start nginx

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Installing nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip >> $LOGFILE

cd /usr/share/nginx/html

unzip -o /tmp/web.zip >> $LOGFILE


cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

systemctl restart nginx
VALIDATE $? "restart nginx"


