terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.78.0"
    }
  }
  backend "gcs" {
    bucket = "f2fdspn0uj"
  }

}

provider "google" {
  project = var.project_id
  region = var.region
}