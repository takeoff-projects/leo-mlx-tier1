#!/bin/bash

#########variables
SEARCH_STRING="gcp+datastore"
PeojectID="roi-takeoff-user7"
##################
if [ $GOOGLE_CLOUD_PROJECT == "" ]; then
	export GOOGLE_CLOUD_PROJECT=$PeojectID
fi
echo "projectID="$GOOGLE_CLOUD_PROJECT

sed 's/ProjectID_PLACEHOLDER/${PeojectID}/' webapplion/.env
sed 's/ProjectID_PLACEHOLDER/${PeojectID}/' terraform/main.tf

cd terraform
#terraform init && terraform apply
if [ -e main_sa.json ]; then
	export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/main_sa.json
	echo "serviceAccountKeyPath="$GOOGLE_APPLICATION_CREDENTIALS
else
	echo "Service account not created, we can't continue"
	exit 1
fi
#gcloud datastore databases create --region=us-central
#gcloud datastore indexes create index.yaml
