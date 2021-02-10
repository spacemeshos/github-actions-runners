data "local_file" "startup_script" {
  filename = "scripts/startup.sh"
}

data "local_file" "shutdown_script" {
  filename = "scripts/shutdown.sh"
}

resource "google_secret_manager_secret" "default" {
  secret_id = "gha-runner"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "default" {
  secret      = google_secret_manager_secret.default.id
  secret_data = <<-EOT
  REPO_NAME=go-spacemesh
  REPO_OWNER=spacemeshos
  GITHUB_TOKEN=${var.github_token}
  REPO_URL=https://github.com/spacemeshos/go-spacemesh
  EOT
}

resource "google_service_account" "default" {
  account_id   = "gha-runner"
  display_name = "A service account for GitHub Actions runners"
}

resource "google_secret_manager_secret_iam_binding" "default" {
  project   = google_secret_manager_secret.default.project
  secret_id = google_secret_manager_secret.default.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

resource "google_compute_instance_template" "default" {
  name         = "gha-runner"
  description  = "This template is used to create dedicated GitHub Actions runner."
  machine_type = var.instance_type

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
  metadata = {
    startup-script  = data.local_file.startup_script.content
    shutdown-script = data.local_file.shutdown_script.content
  }

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2004-lts"
    auto_delete  = true
    boot         = true
  }
  can_ip_forward = true
  network_interface {
    network = "default"
    access_config {
      nat_ip = ""
    }
  }
  depends_on = [google_secret_manager_secret_version.default]
}

resource "google_compute_instance_group_manager" "default" {
  name               = "spacemesh-gha-runner"
  base_instance_name = "spacemesh-gha-runner"
  version {
    instance_template = google_compute_instance_template.default.id
  }
  zone        = var.zone
  target_size = var.min_replicas
  depends_on  = [google_compute_instance_template.default]
}

resource "google_compute_autoscaler" "default" {
  name   = "spacemesh-gha-runner"
  target = google_compute_instance_group_manager.default.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
