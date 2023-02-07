script_location=$(pwd)
LOG=/tmp/roboshop.log

Status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
    else
      echo -e "\e[31mFAILURE\e[0m"
      echo "Refer Log file for more information, LOG - ${LOG}"
  exit
      fi
}
echo -e "\e[35m Configuring NodeJS repos\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
Status_check
echo -e "\e[35m Install NodeJS\e[0m"
yum install nodejs -y &>>${LOG}
Status_check

echo -e "\e[35m Add Application User\e[0m"
useradd roboshop &>>${LOG}
Status_check

mkdir -p /app &>>${LOG}

echo -e "\e[35m Downloading App Content\e[0m"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
Status_check

echo -e "\e[35m Cleanup Old Content\e[0m"
rm -rf /app/* &>>${LOG}
Status_check

echo -e "\e[35m Extracting App Content\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
Status_check

echo -e "\e[35m Installing NodeJS Dependencies\e[0m"
cd /app &>>${LOG}

npm install &>>${LOG}

Status_check
echo -e "\e[35m Configuring Catalogue Service File\e[0m"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
Status_check

echo -e "\e[35m Reload SystemD\e[0m"

systemctl daemon-reload &>>${LOG}
Status_check

echo -e "\e[35m Enable Catalogue Service\e[0m"
systemctl enable catalogue &>>${LOG}

Status_check
echo -e "\e[35m Start Catalogue Service\e[0m"
systemctl start catalogue &>>${LOG}
Status_check

echo -e "\e[35m Configuring Mongo repo\e[0m"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
Status_check

echo -e "\e[35m Install Mongo Client\e[0m"
yum install mongodb-org-shell -y &>>${LOG}
Status_check

echo -e "\e[35m Load Schema\e[0m"
mongo --host mongodb-dev.devopschandra.online </app/schema/catalogue.js &>>${LOG}
Status_check
