provider "google" {
  project = var.project
  zone    = var.zone
  region  = "us-west1"
}

terraform {
  backend "remote" {
    organization = "spacemeshos"
    workspaces {
      name = "gha-runner"
    }
  }
}
