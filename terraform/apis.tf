resource "google_project_service" "api1" {
  service = "appengine.googleapis.com"
}

resource "google_project_service" "api2" {
  service = "datastore.googleapis.com"
}
