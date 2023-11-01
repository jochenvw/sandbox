#/bin/bash

#az login

az group create --name 'nl-stu-jvw-postgresql' --location 'westeurope'
az deployment group create --resource-group 'nl-stu-jvw-postgresql' --template-file 'postgresql.bicep'