resource "google_project_service" "api1" {
  for_each = toset(var.project_apis)

  service = each.value
  disable_dependent_services = true
}










