instance_name = Grafana

[security]
admin_user = ${grafana_admin_user}
admin_password = ${grafana_admin_password}

[server]
http_port = ${grafana_port}

[dashboards]
default_home_dashboard_path = /var/lib/grafana/dashboards/home-dashboard.json
