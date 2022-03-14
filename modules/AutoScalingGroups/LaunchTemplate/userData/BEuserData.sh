#!/bin/bash
sudo yum update -y
sudo yum install java -y
sudo yum install amazon-cloudwatch-agent -y
cd /home/ec2-user
mkdir BE
sudo touch /home/ec2-user/BE/service.log
sudo wget https://github.com/scCloudEngineerProgramVenus/smartbank-modules/raw/boyang/update-backend-for-prod-env/smart-bank-api.jar
sudo wget https://raw.githubusercontent.com/scCloudEngineerProgramVenus/smartbank-modules/rayner/cloudwatch-agent.json/BE-cloudwatch-agent.txt
chmod 777 /opt/aws/amazon-cloudwatch-agent/*
wait
cp BE-cloudwatch-agent.txt /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
wait
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
wait
sudo java -Dspring.datasource.url=jdbc:postgresql://${address}/smartbankdb -jar smart-bank-api.jar &