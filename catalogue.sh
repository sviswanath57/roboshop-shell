#!/bin/bash
#vim /etc/yum.repos.d/mongo.repo

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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Module Disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Module Enable nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Install Nodejs"

id roboshop
if [ $? -ne 0 ]
    then
    useradd roboshop
    VALIDATE $? "User Created"
else
    echo "user exists"
fi

mkdir -p /home/centos/roboshop-shell/app
VALIDATE $? "app dir"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Download Catalogue"

cd /home/centos/roboshop-shell/app

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unziping Catalogue"

npm install &>> $LOGFILE
VALIDATE $? "Catalogue npm installed"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copy done Catalogue.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable catalogue &>> $LOGFILE

systemctl start catalogue

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "mongo.repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "mongodb-org-shell"

mongo --host mangodb.devopslife.cloud </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "catalogue.js loaeded to mongodb"










