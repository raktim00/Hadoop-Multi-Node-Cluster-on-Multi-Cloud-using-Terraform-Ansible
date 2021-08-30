resource "google_compute_network" "gcp_hadoop_vnet" {
  name = "gcp-hadoop-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gcp_hadoop_subnet" {

  depends_on = [
    google_compute_network.gcp_hadoop_vnet
  ]

  name          = "gcp-hadoop-subnet"
  ip_cidr_range = var.gcp-subnet-cidr-block
  region        = var.gcp-region
  network       = google_compute_network.gcp_hadoop_vnet.id
}

resource "google_compute_firewall" "gcp_hadoop_firewall" {

  depends_on = [
    google_compute_network.gcp_hadoop_vnet
  ]

  name    = "gcp-allowall-firewall"
  network = google_compute_network.gcp_hadoop_vnet.id

  allow {
    protocol = "tcp"
  }

  source_tags = ["internet"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "gcp_hadoop_slave" {

  depends_on = [
    google_compute_subnetwork.gcp_hadoop_subnet
  ]

  count = length(var.gcp-instance-name)
  name         = var.gcp-instance-name[count.index]
  machine_type = var.gcp-machine-type
  zone         = var.gcp-zone

  metadata = {
      ssh-keys = "centos:${file("../hadoop-multi-cloud-key-public.pub")}"
  }

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.gcp_hadoop_subnet.self_link
    access_config {}
  }
}