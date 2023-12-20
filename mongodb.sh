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

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "mongo.repo copy"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB" &>> $LOGFILE

systemctl enable mongod
VALIDATE $? "Enable MongoDB" &>> $LOGFILE

systemctl start mongod
VALIDATE $? "Starting MongoDB" &>> $LOGFILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "IP change 127.0.0.1 to 0.0.0.0" &>> $LOGFILE

systemctl restart mongod
VALIDATE $? "Restarting MongoDB" &>> $LOGFILE
