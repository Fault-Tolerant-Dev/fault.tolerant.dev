resource "google_project_service" "project_services" {
  project = var.project_id
  disable_dependent_services = false
  disable_on_destroy = false

  for_each = var.project_services

  service = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }
}


resource "google_dns_managed_zone" "dns_zone" {
  project = var.project_id
  name = "dns-zone"
  dns_name = var.domain_name
}

resource "google_dns_record_set" "dns_record_domain_a" {
  project = var.project_id
  managed_zone = google_dns_managed_zone.dns_zone.name
  name = var.domain_name
  type = "A"
  rrdatas = [google_compute_global_forwarding_rule.glb_forwarding_rule.ip_address]
  ttl = 86400
}

resource "google_dns_record_set" "dns_record_sub_domain_a" {
  project = var.project_id
  managed_zone = google_dns_managed_zone.dns_zone.name
  name = var.sub_domain_name
  type = "A"
  rrdatas = [google_compute_global_forwarding_rule.glb_forwarding_rule.ip_address]
  ttl = 86400
}

resource "google_storage_bucket" "bucket_site" {
  project = var.project_id
  name = "bucket-site"
  location = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.bucket_site.name
  role = "roles/storage.legacyObjectReader"
  member = "allUsers"
}


resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  project = var.project_id
  name = "ssl-cert"

  managed {
    domains = [
      var.domain_name,
      var.sub_domain_name]
  }
}


resource "google_compute_global_forwarding_rule" "glb_forwarding_rule" {
  name = "global-forwarding-rule"
  target = google_compute_target_https_proxy.target_https_proxy.id
  port_range = "443"
}

resource "google_compute_target_https_proxy" "target_https_proxy" {
  name = "target-https-proxy"
  description = "a description"
  url_map = google_compute_url_map.url_map.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.ssl_cert.id]
}

resource "google_compute_url_map" "url_map" {
  name = "url-map"
  description = "a description"
  default_service = google_compute_backend_bucket.backend_bucket.id

  host_rule {
    hosts = [
      var.sub_domain_name]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_bucket.backend_bucket.id

    path_rule {
      paths = [
        "/*"]
      service = google_compute_backend_bucket.backend_bucket.id
    }
  }
}

resource "google_compute_backend_bucket" "backend_bucket" {
  project = var.project_id
  name = "backend-bucket"
  description = "backend bucket"
  bucket_name = google_storage_bucket.bucket_site.name
  enable_cdn = false
}

