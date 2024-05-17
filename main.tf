terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

provider "docker" {
  host     = "${var.connection_type}://${var.ssh_user}@${var.ip}:${var.ssh_port}"
  ssh_opts = ["-i", "${var.ssh_key}", "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

# Templating config files

resource "local_file" "modified_file" {
  filename = "configs/grafana-config.ini"
  content = templatefile("./templates/grafana-config.tpl", {
    grafana_admin_user     = var.grafana_admin_user
    grafana_admin_password = var.grafana_admin_password
  grafana_port = var.grafana_port })
}

# Checking if configs have changes

resource "local_file" "hash" {
  content  = data.archive_file.source.output_md5
  filename = "./.tmp/configs.sha"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "./configs"
  output_path = "./.tmp/configs.zip"
}

# Copying config files 

resource "null_resource" "copy_configs" {
  provisioner "file" {
    source      = "configs"
    destination = "/etc"
  }
  provisioner "file" {
    source      = "./configs/daemon.json"
    destination = "/etc/docker/daemon.json"
  }
  connection {
    host        = var.ip
    type        = var.connection_type
    port        = var.ssh_port
    user        = var.ssh_user
    agent       = "false"
    private_key = file("${var.ssh_key}")
  }
  lifecycle {
    replace_triggered_by = [local_file.hash]
  }
}
