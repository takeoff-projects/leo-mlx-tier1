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


#########variables
SEARCH_STRING="gcp+datastore"
PeojectID="roi-takeoff-user7"
##################
if [ $GOOGLE_CLOUD_PROJECT == "" ]; then
	export GOOGLE_CLOUD_PROJECT=$PeojectID
fi

gcloud auth application-default login
echo "projectID="$GOOGLE_CLOUD_PROJECT

sed -i "s/ProjectID_PLACEHOLDER/${PeojectID}/" webapplion/.env
sed -i "s/ProjectID_PLACEHOLDER/${PeojectID}/" terraform/main.tf
sed -i "s/SEARCH_STRING_PLACEHOLDER/${SEARCH_STRING}/" webapplion/init_database.go

cd terraform
terraform init && terraform apply -auto-approve
if [ -e main_sa.json ]; then
	export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/main_sa.json
	echo "serviceAccountKeyPath="$GOOGLE_APPLICATION_CREDENTIALS
else
	echo "Service account not created, we can't continue"
	exit 1
fi

gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
echo yes | gcloud datastore databases create --region=us-central
echo yes | gcloud datastore indexes create $ROOT_PATH/index.yaml

cd $ROOT_PATH/webapplion
go run init_database.go
###code to build image and push to registry
###code to deploy cloud run
