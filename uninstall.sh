#!/bin/bash

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
cd terraform

if [ -e main_sa.json ]; then
        export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/main_sa.json
        echo "serviceAccountKeyPath="$GOOGLE_APPLICATION_CREDENTIALS
else
        echo "Service account key not found, we can't continue"
        exit 1
fi

#echo yes | gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud auth application-default login
##Here should be code to drop cloud run instance
################################################
cd ${ROOT_PATH}
echo yes | gcloud datastore indexes cleanup index.yaml

cd terraform
terraform init && terraform destroy -auto-approve
