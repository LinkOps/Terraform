# Project: Grafana on Proxmox

This project deploys Grafana to your Proxmox homelab with Terraform, using **LXC by default** and a **VM fallback** when required.

## Why this layout

You asked for separate folders per project. This folder is self-contained so you can learn and iterate on one Terraform project at a time.

## What gets created

- `deployment_mode = "lxc"` (default):
  - Creates a Debian LXC container on Proxmox.
  - Installs Grafana from the official Grafana APT repository.
  - Enables and starts `grafana-server`.
- `deployment_mode = "vm"`:
  - Clones a cloud-init Proxmox VM template.
  - Uses cloud-init to install Docker.
  - Runs Grafana container (`grafana/grafana-oss:latest`) on port `3000`.

## Prerequisites

1. Terraform `>= 1.6`.
2. A Proxmox API token with permissions to create/manage VM and LXC resources.
3. For LXC mode:
   - Debian 12 template present in Proxmox storage (or update `lxc_template`).
   - Network route to SSH into the new container from where Terraform runs.
4. For VM mode:
   - Cloud-init capable template VM matching `vm_clone_template`.
   - Upload `grafana-cloud-init.yaml` to Proxmox snippets storage and reference accordingly.

## Quick start

```bash
cd projects/grafana-proxmox
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your own values
terraform init
terraform plan
terraform apply
```

After apply, open output URL (typically `http://<ip>:3000`).

Default Grafana credentials are typically:
- Username: `admin`
- Password: `admin` (you will be forced to reset on first login)

## Connecting Grafana to Home Assistant

For Home Assistant OS, the default Recorder database is normally **SQLite** unless you explicitly configure another database engine.

Practical next steps:
1. In Home Assistant, check `configuration.yaml` for a `recorder:` section.
2. If no external DB is configured, consider moving to MariaDB or PostgreSQL for long-term metrics.
3. In Grafana, add one of these data-source approaches:
   - PostgreSQL / MySQL directly (if you migrate Recorder to these),
   - Prometheus (if you export HA metrics there),
   - InfluxDB (if HA writes time-series there).

## Notes

- LXC is preferred for lightweight homelab workloads.
- VM mode exists as a fallback when LXC constraints make the stack impractical.
