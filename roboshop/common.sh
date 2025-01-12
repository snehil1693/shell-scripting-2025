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

ADD_APPLICATION_USER() {
  PRINT "Add Roboshop Applicaion User"
  id roboshop &>>$LOG
  if [ $? -ne 0 ];then
    useradd roboshop &>>$LOG
  fi
  STAT_CHECK $?
}

DOWNLOAD_APP_CODE() {
    PRINT "Download Applicaion Code"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>$LOG
    STAT_CHECK $?

    PRINT "Extract Downloaded Code\t"
    cd /home/roboshop && unzip -o /tmp/${COMPONENT}.zip &>>$LOG && rm -rf ${COMPONENT} && mv ${COMPONENT}-main ${COMPONENT}
    STAT_CHECK $?
}

PREM_FIX() {
  PRINT "FIX Applicaion Permissions"
  chown roboshop:roboshop /home/roboshop -R &>>$LOG
  STAT_CHECK $?
}

SETUP_SYSTEMD() {
  PRINT "Setup SystemD file\t"
  sed -i -e "s/MONGO_DNSNAME/mongodb.roboshop.internal/" -e "s/REDIS_ENDPOINT/redis.roboshop.internal/" -e "s/MONGO_ENDPOINT/mongodb.roboshop.internal/" -e "s/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/" -e "s/CARTENDPOINT/cart.roboshop.internal/" -e "s/DBHOST/mysql.roboshop.internal/" -e "s/CARTHOST/cart.roboshop.internal/" -e "s/USERHOST/user.roboshop.internal/" -e "s/AMQPHOST/rabbitmq.roboshop.internal/" /home/roboshop/${COMPONENT}/systemd.service && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
  STAT_CHECK $?

  PRINT "Start Catalogue Service\t"
  systemctl daemon-reload &>>$LOG && systemctl restart ${COMPONENT} &>>$LOG && systemctl enable ${COMPONENT} &>>$LOG
  STAT_CHECK $?
}

NODEJS() {
  PRINT "Install Nodejs\t\t"
  yum install nodejs make gcc-c++ -y &>>$LOG
  STAT_CHECK $?

  ADD_APPLICATION_USER
  DOWNLOAD_APP_CODE

  PRINT "Install Nodejs Dependencies"
  cd /home/roboshop/${COMPONENT} && npm install --unsafe perm &>>$LOG
  STAT_CHECK $?

  PREM_FIX
  SETUP_SYSTEMD


}

JAVA() {
  PRINT "Install Maven\t\t"
  yum install maven -y &>>$LOG
  STAT_CHECK $?

  ADD_APPLICATION_USER
  DOWNLOAD_APP_CODE

  PRINT "Compile Code\t\t"
  cd /home/roboshop/${COMPONENT} && mvn clean package &>>$LOG && mv target/shipping-1.0.jar shipping.jar
  STAT_CHECK $?

  PREM_FIX
  SETUP_SYSTEMD

}

PYTHON3() {
  PRINT "Install Python3\t\t"
  yum install python36 gcc python3-devel -y &>>$LOG
  STAT_CHECK $?

  ADD_APPLICATION_USER
  DOWNLOAD_APP_CODE

  PRINT "Install Python Dependencies"
  cd /home/roboshop/${COMPONENT} && pip3 install -r requirements.txt &>>$LOG
  STAT_CHECK $?

  PRINT "Update Service Configuration"
  userID=$(id -u roboshop)
  groupID=$(id -g roboshop)
  sed -i -e "/uid/ c uid = ${userID}" -e "/gid/ c gid = ${groupID}" payment.ini &>>$LOG
  STAT_CHECK $?

  PREM_FIX
  SETUP_SYSTEMD

}