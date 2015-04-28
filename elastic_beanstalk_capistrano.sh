#!/bin/bash

# Script to create the capistano user on each of the given remote hosts and to download the authorized keys file to his home

# Roughly the process for remote process execution is:
# for host in hostA hostB ... hostZ ; do ssh -i /keys/thekey.pem -l default_user -oStrictHostKeyChecking=no $host remote_command ; done
# And we do that for the commands that we need.

echo "Provided arguments were:"

if [ $# -eq 0 ]
then
  echo "derp. please provide a hostname or IP address... seriously d00d."
  exit 1
else
  echo "$@"
fi

echo "Attempting to login"

for host in $@
do
  echo "Working on host $host"
  echo "Adding user..."
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo useradd -m capistrano -s /bin/bash -G wheel
  echo "Done."
  echo "Setting up sudo..."
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host -C "echo \"capistrano ALL=(ALL) NOPASSWD:ALL\" >> /tmp/capistrano-init"
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo chown root:root /tmp/capistrano-init
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo chmod 440 /tmp/capistrano-init
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo mv /tmp/capistrano-init /etc/sudoers.d/capistrano-init
  echo "Done."
  echo "Setting up SSH."
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo mkdir /home/capistrano/.ssh
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo wget https://deploy.quicktravel.com.au/authorized_keys2.txt -O /home/capistrano/.ssh/authorized_keys
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo chown -R capistrano:capistrano /home/capistrano/.ssh
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo chmod 700 /home/capistrano/.ssh
  ssh -t -i ~/Downloads/the_stef.pem -l ec2-user -oStrictHostKeyChecking=no $host sudo chmod 600 /home/capistrano/.ssh/authorized_keys
  echo "Done."
  echo "Final test..."
  ssh -l capistrano -oStrictHostKeyChecking=no $host -C "echo Capistrano is Alive"
done

