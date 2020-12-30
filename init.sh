#!/bin/bash

echo "Provisioning Terraform resources"
terraform apply -auto-approve

PUBLIC_IP=$(terraform output master_public_ip)
PRIVATE_MASTER_IP=$(terraform output master_private_ip)
PRIVATE_SLAVE_IP_0=$(terraform output -json slave_private_ips | jq '.[0]' )
PRIVATE_SLAVE_IP_1=$(terraform output -json slave_private_ips | jq '.[1]' )
PRIVATE_SLAVE_IP_2=$(terraform output -json slave_private_ips | jq '.[2]' )

echo "Prepering inventory file"
cp inventory_tmp.ini inventory.ini
sed -i "s/MASTER_PRIVATE_IP/${PRIVATE_MASTER_IP}/g" inventory.ini
sed -i "s/SLAVE_PRIVATE_IP_0/${PRIVATE_SLAVE_IP_0}/g" inventory.ini
sed -i "s/SLAVE_PRIVATE_IP_1/${PRIVATE_SLAVE_IP_1}/g" inventory.ini
sed -i "s/SLAVE_PRIVATE_IP_2/${PRIVATE_SLAVE_IP_2}/g" inventory.ini

scp -o StrictHostKeyChecking=no -i ~/Shared/jmetertests.pem ~/Shared/jmetertests.pem ec2-user@${PUBLIC_IP}:/home/ec2-user/.ssh/
scp -o StrictHostKeyChecking=no -i ~/Shared/jmetertests.pem inventory.ini ec2-user@${PUBLIC_IP}:/home/ec2-user/
rm -f inventory.ini
scp -o StrictHostKeyChecking=no -i ~/Shared/jmetertests.pem setup.sh ec2-user@${PUBLIC_IP}:/home/ec2-user/
ssh -o StrictHostKeyChecking=no -i ~/Shared/jmetertests.pem ec2-user@${PUBLIC_IP} /home/ec2-user/setup.sh
