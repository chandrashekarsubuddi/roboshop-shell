script_location=$(pwd)
LOG=/tmp/roboshop.log

Status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[1;32mSUCCESS\e[0m"
    else
      echo -e "\e[1;31mFAILURE\e[0m"
      echo "Refer Log file for more information, LOG - ${LOG}"
  exit
      fi
}

print_head() {
  echo -e "\e[1m $1 \e[0m"
}

APP_PREREQ() {

print_head "Add Application User"
  id roboshop &>>${LOG}
  if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG}
  fi
  Status_check

  mkdir -p /app &>>${LOG}

  print_head "Downloading App Content"
    curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
    Status_check

    print_head "Cleanup Old Content"
      rm -rf /app/* &>>${LOG}
      Status_check

      print_head "Extracting App Content"
        cd /app
        unzip /tmp/${component}.zip &>>${LOG}
        Status_check

}

SYSTEMD_SETUP() {
  print_head "Configuring ${component} Service File"
    cp ${script_location}/files/${component}.service /etc/systemd/system/${component}.service &>>${LOG}
    Status_check

    print_head "Reload SystemD"

    systemctl daemon-reload &>>${LOG}
    Status_check

    print_head "Enable ${component} Service"
    systemctl enable ${component} &>>${LOG}
    Status_check

    print_head "Start ${component} Service"
    systemctl start ${component} &>>${LOG}
    Status_check

}

LOAD_SCHEMA() {
  if [ ${schema_load} == "true" ]; then
    if [ ${schema_type} == "mongo" ]; then
    print_head "Configuring Mongo repo"
    cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
    Status_check

    print_head "Install Mongo Client"
    yum install mongodb-org-shell -y &>>${LOG}
    Status_check

    print_head "Load Schema"
    mongo --host mongodb-dev.devopschandra.online </app/schema/${component}.js &>>${LOG}
    Status_check
    fi

    if [ ${schema_type} == "mysql" ]; then

        print_head "Install MySQL Client"
        yum install mysql -y &>>${LOG}
        Status_check

        print_head "Load Schema"
        mysql -h mysql-dev.devopschandra.online -uroot -p${root_mysql_password} < /app/schema/shipping.sql
        Status_check
        fi
    fi
}
NODEJS() {
  source common.sh
  print_head "Configuring NodeJS Repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  Status_check

  print_head "Install NodeJS"
  yum install nodejs -y &>>${LOG}
  Status_check

APP_PREREQ

  print_head "Installing NodeJS Dependencies"
  cd /app &>>${LOG}

  npm install &>>${LOG}

  Status_check

  SYSTEMD_SETUP

  LOAD_SCHEMA
}

MAVEN() {
  print_head "Install Maven"
    yum install maven -y &>>${LOG}
    Status_check

    APP_PREREQ

   print_head "Build a package"
   mvn clean package &>>${LOG}
   Status_check

   print_head "Copy App file to App location"
   mv target/${component}-1.0.jar ${component}.jar &>>${LOG}
   Status_check

   SYSTEMD_SETUP

   LOAD_SCHEMA

}

PAYTHON() {
  print_head "Install Python"
      yum install python36 gcc python3-devel -y &>>${LOG}
      Status_check

      APP_PREREQ

     print_head "Download Dependencies"
     cd /app
     pip3.6 install -r requirements.txt &>>${LOG}
     Status_check

     print_head "Update passwords in Service File"
          sed -i -e "s/roboshop_rabbitmq_password/${roboshop_rabbitmq_password}/" files/${component}.service &>>${LOG}
          Status_check

     SYSTEMD_SETUP

}