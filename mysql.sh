source common.sh

if [ -z "${root_mysql_password}" ]; then
  echo "Variable root_mysql_password is missing"
  exit
  fi

print_head "Disable MySQL Default Module"
dnf module disable mysql -y
Status_check

print_head "Copy MySQL Repo File"
cp ${script_location}/files/mysql.repo /etc/yum.repos.d/mysql.repo &>>${LOG}
Status_check

print_head "Install MySQL Server"
yum install mysql-community-server -y &>>${LOG}
Status_check

print_head "Enable MySQL Server"
systemctl enable mysqld
Status_check

print_head "Start MySQL Server"
systemctl start mysqld
Status_check

print_head "Reset Default Database Password"
mysql_secure_installation --set-root-pass ${root_mysql_password} &>>${LOG}
Status_check