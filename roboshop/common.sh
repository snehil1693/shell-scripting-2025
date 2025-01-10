#!/bain/bash

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ] ; then
  echo -e "\e[31mYou should be a root user / sudo user to run this script\e[0m"
  exit 2
fi

LOG=/tmp/roboshop.log
rm -rd $LOG

STAT_CHECK(){
  if [ $1 -eq 0 ]; then
    echo -e "\e[32m done\e[0m"
  else
    echo -e "\e[31m fail\e[0m"
  ## so if the code fail it should not move forward
    echo -e "\e[33m Check the log file for more details, log file - $LOG\e[0m"
    exit 1
  fi
}

PRINT(){
  echo -e "##############################\t$1\t##############################" &>>$LOG
  echo -n -e "$1\t\t..."
}

NODEJS() {
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
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>$LOG
  STAT_CHECK $?

  PRINT "Extract Downloaded Code\t"
  cd /home/roboshop && unzip -o /tmp/${COMPONENT}.zip &>>$LOG && rm -rf ${COMPONENT} && mv ${COMPONENT}-main ${COMPONENT}
  STAT_CHECK $?

  PRINT "Install Nodejs Dependencies"
  cd /home/roboshop/${COMPONENT} && npm install --unsafe perm &>>$LOG
  STAT_CHECK $?

  PRINT "FIX Applicaion Permissions"
  chown roboshop:roboshop /home/roboshop -R &>>$LOG
  STAT_CHECK $?

  PRINT "Setup SystemD file\t"
  sed -i -e "s/MONGO_DNSNAME/mongodb.roboshop.internal/" -e "s/REDIS_ENDPOINT/redis.roboshop.internal/" -e "s/MONGO_ENDPOINT/mongodb.roboshop.internal/" /home/roboshop/${COMPONENT}/systemd.service && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
  STAT_CHECK $?

  PRINT "Start Catalogue Service\t"
  systemctl daemon-reload &>>$LOG && systemctl start ${COMPONENT} &>>$LOG && systemctl enable ${COMPONENT} &>>$LOG
  STAT_CHECK $?

}