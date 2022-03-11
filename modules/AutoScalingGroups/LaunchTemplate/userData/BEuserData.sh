#!/bin/bash
sudo yum update -y
sudo yum install java -y
sudo wget https://github.com/scCloudEngineerProgramVenus/smartbank-modules/raw/boyang/update-backend-for-prod-env/smart-bank-api.jar
sudo java -Dspring.datasource.url=jdbc:postgresql://${address}/smartbankdb -jar smart-bank-api.jar &