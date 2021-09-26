resource "google_project_service" "api" {
  for_each = toset(var.project_apis)

  service = each.value
  disable_dependent_services = true
}










