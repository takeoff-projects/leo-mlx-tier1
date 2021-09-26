resource "google_project_service" "api1" {
  for_each = var.project_apis

  service = each.key
  disable_dependent_services = true
}










