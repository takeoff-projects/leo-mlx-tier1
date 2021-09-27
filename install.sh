#!/bin/bash

#########variables
SEARCH_STRING="aws+eks"
PeojectID="roi-takeoff-user7"
GOOGLE_ACCOUNT="touser7@roigcp.com"
##################


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

if [ $GOOGLE_CLOUD_PROJECT == "" ]; then
	export GOOGLE_CLOUD_PROJECT=$PeojectID
fi

gcloud auth application-default login
echo "projectID="$GOOGLE_CLOUD_PROJECT

sed -i "s/ProjectID_PLACEHOLDER/${PeojectID}/" webapplion/.env
sed -i "s/ProjectID_PLACEHOLDER/${PeojectID}/" terraform/main.tf
sed -i "s/SEARCH_STRING_PLACEHOLDER/${SEARCH_STRING}/" webapplion/init_database.go
sed -i "s/GOOGLE_ACCOUNT_PLACEHOLDER/${GOOGLE_ACCOUNT}/" uninstall.sh

cd terraform
terraform init && terraform apply -auto-approve

#gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud config set account $GOOGLE_ACCOUNT
echo yes | gcloud datastore databases create --region=us-central
echo yes | gcloud datastore indexes create $ROOT_PATH/index.yaml

cd $ROOT_PATH/webapplion
go run init_database.go

###code to build image and push to registry
###code to deploy cloud run



if [ -e main_sa.json ]; then
        export GOOGLE_APPLICATION_CREDENTIALS=$ROOT_PATH/terraform/main_sa.json
        echo "serviceAccountKeyPath="$GOOGLE_APPLICATION_CREDENTIALS
else
        echo "Service account not created, we can't continue"
        exit 1
fi

