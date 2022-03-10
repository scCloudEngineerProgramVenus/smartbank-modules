#!/bin/bash
yum update -y
yum install git curl -y
cd /home/ec2-user/
curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash
sudo yum install -y nodejs
git clone https://github.com/scCloudEngineerProgramVenus/smartbank-modules.git
cd /home/ec2-user/smartbank-modules/
git checkout rayner/FE-point-to-BE-LB
git pull origin
cd /home/ec2-user/smartbank-modules/module3/
sudo echo "export const API_URL = 'http://${ALB_address}:8080/'" > src/Constants.js
npm install
PORT=80 npm run start&