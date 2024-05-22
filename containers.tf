
# Creating docker network

resource "docker_network" "private_network" {
  name   = "internal"
  driver = "bridge"
}

# Pulling containers:

variable "docker_images" {
  default = {
    grafana       = "grafana/grafana:latest"
    loki          = "grafana/loki:latest"
    promtail      = "grafana/promtail:latest"
    prometheus    = "prom/prometheus:latest"
    node-exporter = "prom/node-exporter:latest"
  }
}

resource "docker_image" "images" {
  for_each     = var.docker_images
  name         = var.docker_images[each.key]
  keep_locally = true
}

# Run Grafana

resource "docker_container" "grafana" {
  name         = "grafana"
  image        = docker_image.images["grafana"].image_id
  restart      = var.restart_policy
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.private_network.name
  }
  volumes {
    container_path = "/etc/grafana/provisioning/datasources/datasources.yaml"
    host_path      = "/etc/configs/datasources.yaml"
  }
  volumes {
    container_path = "/etc/grafana/grafana-config.ini"
    host_path      = "/etc/configs/grafana-config.ini"
  }
  volumes {
    container_path = "/etc/grafana/provisioning/dashboards/provisioner.yml"
    host_path      = "/etc/configs/provisioner.yml"
  }
  volumes {
    container_path = "/var/lib/grafana/dashboards"
    host_path      = "/etc/configs/dashboards"
  }
  env = [
    "GF_PATHS_PROVISIONING=/etc/grafana/provisioning",
    "GF_PATHS_CONFIG=/etc/grafana/grafana-config.ini"
  ]
  ports {
    external = var.grafana_port
    internal = var.grafana_port
  }
  lifecycle {
    ignore_changes       = [network_mode, log_opts]
    replace_triggered_by = [local_file.hash]
  }
}

# Run Prometheus

resource "docker_container" "prometheus" {
  name         = "prometheus"
  image        = docker_image.images["prometheus"].image_id
  restart      = var.restart_policy
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.private_network.name
  }

  volumes {
    container_path = "/etc/prometheus/prometheus.yml"
    host_path      = "/etc/configs/prometheus-config.yaml"
  }
  volumes {
    container_path = "/prometheus"
    host_path      = "/prometheus"
  }
  user = var.managment_user
  lifecycle {
    ignore_changes       = [network_mode, log_opts]
    replace_triggered_by = [local_file.hash]
  }
}

# Run Loki

resource "docker_container" "loki" {
  name         = "loki"
  image        = docker_image.images["loki"].image_id
  restart      = var.restart_policy
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.private_network.name
  }
  volumes {
    container_path = "/etc/loki/local-config.yaml"
    host_path      = "/etc/configs/loki-config.yaml"
  }
  volumes {
    container_path = "/tmp/loki/chunks"
    host_path      = "/loki/chunks"
  }
  volumes {
    container_path = "/tmp/loki/rules"
    host_path      = "/loki/rules"
  }
  user = var.managment_user
  lifecycle {
    ignore_changes       = [network_mode, log_opts]
    replace_triggered_by = [local_file.hash]
  }
    ports {
    ip       = "127.0.0.1"
    external = 3100
    internal = 3100
  }
}

# Run Promtail

resource "docker_container" "promtail" {
  name         = "promtail"
  image        = docker_image.images["promtail"].image_id
  restart      = var.restart_policy
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.private_network.name
  }
  volumes {
    container_path = "/var/log/"
    host_path      = "/var/log/"
  }
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }
  volumes {
    container_path = "/etc/promtail/config.yml"
    host_path      = "/etc/configs/promtail-config.yaml"
  }
  ports {
    ip       = "127.0.0.1"
    external = 3200
    internal = 3200
  }
  lifecycle {
    ignore_changes       = [network_mode, log_opts]
    replace_triggered_by = [local_file.hash]
  }
}

# Run node-exporter

resource "docker_container" "node-exporter" {
  name         = "node-exporter"
  image        = docker_image.images["node-exporter"].image_id
  restart      = var.restart_policy
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.private_network.name
  }
  lifecycle {
    ignore_changes       = [network_mode, log_opts]
    replace_triggered_by = [local_file.hash]
  }
}