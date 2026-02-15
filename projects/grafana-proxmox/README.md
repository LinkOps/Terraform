# Project: Grafana on Proxmox

This project deploys Grafana to your Proxmox homelab with Terraform, using **LXC by default** and a **VM fallback** when required.

## Why this layout

You asked for separate folders per project, with reusable shared configuration when appropriate:

- Project-specific code lives here: `projects/grafana-proxmox`
- Shared Proxmox/network config lives in: `shared/home-lab.json`

## Shared config stencil

Create your own shared config from the provided example:

```bash
cp shared/home-lab.example.json shared/home-lab.json
```

Then edit:
- `proxmox_hosts`: one entry per Proxmox host/node
  - `api_token_id` and `api_token_secret` per host
  - `storage_pools` per host with purpose-based split:
    - `lxc_rootfs` (LXC disk)
    - `vm_disk` (VM disk)
    - `snippets` (cloud-init snippets storage)
- `network_profiles`: reusable network defaults (bridge, gateway, dns)

This lets each project pick a host target without duplicating host/network settings.

## What gets created

- `deployment_mode = "lxc"` (default):
  - Creates a Debian LXC container on selected Proxmox host.
  - Installs Grafana from the official Grafana APT repository.
  - Enables and starts `grafana-server`.
- `deployment_mode = "vm"`:
  - Clones a cloud-init Proxmox VM template on selected host.
  - Uses cloud-init to install Docker.
  - Runs Grafana container (`grafana/grafana-oss:latest`) on port `3000`.

## Prerequisites

1. Terraform `>= 1.6`.
2. Proxmox API tokens configured in `shared/home-lab.json` for each host you plan to target.
3. For LXC mode:
   - Debian 12 template present in Proxmox storage (or update `lxc_template`).
   - Network route to SSH into the new container from where Terraform runs.
4. For VM mode:
   - Cloud-init capable template VM matching `vm_clone_template`.
   - Upload `grafana-cloud-init.yaml` to your chosen snippets storage.

## Quick start

```bash
cp shared/home-lab.example.json shared/home-lab.json
cd projects/grafana-proxmox
cp terraform.tfvars.example terraform.tfvars
# edit shared/home-lab.json and terraform.tfvars
terraform init
terraform plan
terraform apply
```

In `terraform.tfvars`, set:
- `proxmox_host_key` to the host entry (for example `pve1`, `pve2`)
- `network_profile_key` to the shared network profile (for example `lan`)

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
