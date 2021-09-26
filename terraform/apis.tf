resource "google_project_service" "api1" {
  service = "appengine.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "api2" {
  service = "datastore.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "api3" {
  service = "cloudapis.googleapis.com"
  disable_dependent_services = true
}
