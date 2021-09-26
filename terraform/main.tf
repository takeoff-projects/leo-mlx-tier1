provider "google" {

  project = "roi-takeoff-user7"
  region  = "multi-regional"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "google_service_account" "main_sa" {
  account_id   = "main-sa"
  display_name = "Project owner service account"
}

resource "google_project_iam_member" "main_sa_role" {
  role   = "roles/owner"
  member = "serviceAccount:${google_service_account.main_sa.email}"
  depends_on = [
    google_service_account.main_sa,
  ]
}

resource "google_service_account_key" "main_sa_credentials" {
  service_account_id = "${google_service_account.main_sa.account_id}"
}

resource "local_file" "main_sa_json" {
  content  = "${base64decode(google_service_account_key.main_sa_credentials.private_key)}"
  filename = "${path.module}/main_sa.json"
  depends_on = [
    google_service_account_key.main_sa_credentials
  ]
}

module "datastore" {
  source      = "./terraform-google-cloud-datastore"
#  credentials = "${path.module}/main_sa.json"
  project     = "roi-takeoff-user7"
  indexes     = "index.yaml"
  depends_on = [
    local_file.main_sa_json
  ]
}
