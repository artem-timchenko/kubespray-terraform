#!/bin/bash

mv .ssh/jmetertests.pem .ssh/id_rsa
chmod 400 .ssh/id_rsa

sudo yum install -y git
sudo yum install -y python3
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray/
git checkout release-2.14
sudo pip3 install -r requirements.txt
cp -rfp inventory/sample inventory/mycluster
mv ../inventory.ini inventory/mycluster/
ansible-playbook -i inventory/mycluster/inventory.ini -u ec2-user -b cluster.yml

USERNAME=$(whoami)
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $USERNAME:$USERNAME ~/.kube/config
