# leo-mlx-tier1

This repo could be used for deploy application with cloudRun 
Application uses Datastore as backend

You need clone this repo, modify variables in install.sh script to match your values:
```
#########variables
SEARCH_STRING="gcp+spanner"
PeojectID="roi-takeoff-user7"
GOOGLE_ACCOUNT="touser7@roigcp.com"
GOOGLE_REGION="us-central1"
##################

```

SEARCH_STRING variable used for search across github repos, you can specify any value here

To deploy application you can run this command:
```
git clone https://github.com/takeoff-projects/leo-mlx-tier1.git && cd leo-mlx-tier1 && ./start_my_app.sh
```

This command will ask for authentication in GCP
Last row in output will be the link on deployed application.

Prerequisites: you need installed terraform v1.x, go 1.17 and gcloud
You can run this command in any terminal, however better use cloud shell

To uninstall application run ./uninstall.sh script inside leo-mlx-tier1 folder.
Uninstall script will ask GCP authentication as well.

API endpoints:

