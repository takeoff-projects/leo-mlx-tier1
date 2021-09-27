#!/bin/bash

#########variables
##################
if [ $GOOGLE_CLOUD_PROJECT == "" ]; then
	export GOOGLE_CLOUD_PROJECT=roi-takeoff-user7
fi
echo $GOOGLE_CLOUD_PROJECT
cd terraform
#terraform init && terraform apply
if [ -e main_sa.json ]; then
	export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/main_sa.json
	echo $GOOGLE_APPLICATION_CREDENTIALS
else
	echo "Service account not created, we can't continue"
	exit 1
fi
#gcloud datastore databases create --region=us-central
#gcloud datastore indexes create index.yaml
