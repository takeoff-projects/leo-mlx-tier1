variable "project_apis"  {
type = list(string)
default = [
  "appengine.googleapis.com",
  "cloudapis.googleapis.com",
  "cloudbuild.googleapis.com",
  "run.googleapis.com",
  "servicemanagement.googleapis.com",
  "servicecontrol.googleapis.com",
  "apigateway.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "datastore.googleapis.com",
  "iam.googleapis.com"
]
}
