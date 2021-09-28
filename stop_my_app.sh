#!/bin/bash

###variable
GOOGLE_ACCOUNT=GOOGLE_ACCOUNT_PLACEHOLDER

###check if commands installed
if ! terraform_installed="$(type -p "terraform")" || [[ -z $terraform_installed ]]; then
	echo "terraform is not installed. Exiting..."
	exit 1
fi
if ! go_installed="$(type -p "go")" || [[ -z $go_installed ]]; then
        echo "go is not installed. Exiting..."
        exit 1
fi
if ! gcloud_installed="$(type -p "go")" || [[ -z $gcloud_installed ]]; then
        echo "gcloud is not installed. Exiting..."
        exit 1
fi

ROOT_PATH=$(pwd)
#cd terraform

gcloud auth application-default login
gcloud config set account $GOOGLE_ACCOUNT
### code to uninstall api gateway
echo yes | gcloud beta api-gateway gateways delete github-search-api-gw --location=GOOGLE_REGION_PLACEHOLDER
echo yes | gcloud beta api-gateway api-configs delete github-search-config --api=github-search-api
################################################
##Here should be code to drop cloud run instance
echo yes | gcloud run services delete github-search --region=GOOGLE_REGION_PLACEHOLDER
################################################
cd ${ROOT_PATH}/scripts
go run datastore_cleanup.go
cd ${ROOT_PATH}
echo yes | gcloud datastore indexes cleanup ${ROOT_PATH}/index.yaml

cd ${ROOT_PATH}/terraform
gcloud auth list
terraform init && terraform destroy -auto-approve
