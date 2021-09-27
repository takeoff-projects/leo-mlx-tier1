variable "project_apis"  {
type = list(string)
default = [
  "appengine.googleapis.com",
  "cloudapis.googleapis.com",
  "cloudbuild.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "datastore.googleapis.com",
  "iam.googleapis.com"
]
}
