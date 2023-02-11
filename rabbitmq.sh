source common.sh

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "Variable roboshop_rabbitmq_password is missing"
  exit
  fi

print_head "Configuring Erlang YUM Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${LOG}
Status_check

print_head "Configuring RabbitMQ YUM Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG}
Status_check

print_head "Install Erlang & RabbitMQ"
yum install erlang rabbitmq-server -y &>>${LOG}
Status_check

print_head "Enable RabbitMQ server"
systemctl enable rabbitmq-server &>>${LOG}
Status_check

print_head "Start RabbitMQ server"
systemctl start rabbitmq-server &>>${LOG}
Status_check

print_head "Add Application User"
rabbitmqctl add_user roboshop ${roboshop_rabbitmq_password} &>>${LOG}
Status_check

print_head "Add Tags to Application User"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG}
Status_check

print_head "Add Permission to Application User"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
Status_check