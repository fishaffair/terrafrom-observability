## Terraform workflow for deploying Grafana Observavilisty Stack in Docker
# (Grafana-Loki-Promtail-Prometheus)
With fancy docker dashboards.

Dashboards screenshots:

![Alt text](/img/dashboard1.png "dashboard1")
![Alt text](/img/dashboard2.png "dashboard2")

## Usage
1. Clone repo
1. Place your variables info `terraform.tfvars` file
1. Run 
    ```
    terraform init --upgrade
    terraform plan
    terrafom apply --parallelism=1
    ```

> [!IMPORTANT]
> The `--parallelism=1` flag is useful for overpassing docker socket connection limit over ssh.

Documentation about docker terraform provider can be viewed on [library.tf](https://library.tf/providers/kreuzwerker/docker/latest)
