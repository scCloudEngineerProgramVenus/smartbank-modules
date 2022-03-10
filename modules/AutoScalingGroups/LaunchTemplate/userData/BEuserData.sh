#!/bin/bash
yum update -y
yum install java -y
wget https://github.com/scCloudEngineerProgramVenus/smartbank-modules/raw/boyang/update-backend-for-prod-env/smart-bank-api.jar
java -jar smart-bank-api.jar &
#java -Dspring.datasource.url=jdbc:postgresql://{DB_address}:5432/smartbankdb -jar smart-bank-api.jar &