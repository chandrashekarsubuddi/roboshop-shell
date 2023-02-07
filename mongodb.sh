source common.sh

print_head "Copy Mongodb Repo file"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
Status_check

print_head "Install MongoDB"
yum install mongodb-org -y &>>${LOG}
Status_check

print_head "Update MongoDB Listen Address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG}
Status_check

print_head "Install MongoDB"
systemctl enable mongod &>>${LOG}
Status_check

print_head "Install MongoDB"
systemctl restart mongod &>>${LOG}
Status_check