variable "ip" {
  type      = string
  sensitive = true
}

variable "ssh_port" {
  type      = string
  default   = "22"
  sensitive = true
}

variable "ssh_user" {
  type      = string
  sensitive = true
}

variable "connection_type" {
  type    = string
  default = "ssh"
}

variable "ssh_key" {
  type      = string
  default   = "~\\.ssh\\key"
  sensitive = true
}

variable "log_opts" {
  type    = string
  default = "{{.ImageName}}|{{.Name}}|{{.ImageFullID}}|{{.FullID}}"
}

variable "grafana_admin_user" {
  type      = string
  default   = "grafana_user"
  sensitive = true
}

variable "grafana_admin_password" {
  type      = string
  default   = "grafana_password"
  sensitive = true
}

variable "grafana_port" {
  type    = number
  default = 3000
}

variable "container_stop_timeout" {
  type    = number
  default = 10
}

variable "container_read_timeout_milliseconds" {
  type    = number
  default = 10000
}

variable "restart_policy" {
  type    = string
  default = "always"
}

variable "managment_user" {
  type    = string
  default = "root"
}