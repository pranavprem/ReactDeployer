# Agent guide

This is the guide for working in ReactDeployer. [CLAUDE.md](CLAUDE.md) points here. Prefer this file over rediscovering the layout.

## Architecture

Two roots, three modules.

- `bootstrap/` is its own root module. It calls `modules/backend` and keeps **local** state. It exists so the state bucket can be created before anything tries to use it. The original repo loaded that module in the same root as the app and told the reader to blank out files between applies. Terraform loads every `.tf` file, so that workflow does not work.
- The repository root is the application stack. `versions.tf` has a partial S3 backend (`backend "s3" {}`). Real bucket settings come from `backend.hcl` at `terraform init -backend-config=backend.hcl`.
- `modules/launch_template` builds the AMI lookup, SSH key, instance security group, and user-data.
- `modules/autoscaling_loadbalancing` builds the default-VPC lookup, load balancer, target group, and Auto Scaling group. It consumes the launch template id and version. It does not create the launch template.
- `local.name_slug` in the root is the only AWS name prefix. Both modules receive it. Load balancer names are limited to 32 characters, so the slug is capped at 24 (`<slug>-alb`).

The boot path is `modules/launch_template/user-data.sh`. Cloud-init installs Node.js from nodejs.org (checksum verified), clones the public repo as the `react` user, runs `npm install`, and starts `npm run dev` via `react-dev.service`.

## Conventions

- Terraform fmt is the formatter. Two-space indent, no fmt config file beyond `.editorconfig`. Run `terraform fmt -recursive` and commit the result.
- Provider versions are pinned with `~> ` constraints and `.terraform.lock.hcl`. Commit the lock file. Do not gitignore it. When you bump a provider, run `terraform providers lock` for linux_amd64, linux_arm64, darwin_amd64, darwin_arm64, and windows_amd64 in both roots.
- Providers are configured only in the roots (`provider "aws"` in `main.tf` and `bootstrap/main.tf`). Modules declare `required_providers` and do not contain provider blocks.
- Variable defaults that define a deployment live on the root module. Module variables are required when the root always passes them, so the two halves cannot drift back to different defaults.
- `name_slug`, not the raw GitHub name, goes into AWS name fields. Security group and key material can use the slug too.
- User-data is a `templatefile()`. Terraform interpolations are `${name}`. Bash interpolations in that file must be written `$${name}` or Terraform will try to evaluate them.
- Shell scripts and Terraform files are LF (`.gitattributes`). A CRLF shebang breaks cloud-init.
- Do not add a license file.
- Do not commit `backend.hcl`, `*.tfvars`, state, plan files, `.terraform/`, or generated PEM keys.

## Commands

Safe checks, and the ones CI runs. They do not talk to AWS:

```bash
terraform fmt -check -recursive -diff
terraform init -backend=false -input=false
terraform validate
terraform -chdir=bootstrap init -backend=false -input=false
terraform -chdir=bootstrap validate
tflint --init
tflint --format compact
tflint --chdir=bootstrap --config "$(pwd)/.tflint.hcl" --format compact
```

CI is `.github/workflows/terraform.yml`. It installs Terraform 1.16.6 and TFLint 0.64.0. Keep those pins aligned with `required_version` and `.tflint.hcl` when you bump them.

`terraform plan` and `terraform apply` need real credentials and, for the application root, a real backend. They take a state lock and call AWS. Do not run them unless the user explicitly asks. Never run `terraform apply` from CI.

A human deploy is documented in [README.md](README.md): bootstrap apply, write `backend.hcl`, then application init and apply, then `./test.sh`.

## Gotchas

- **Default VPC.** Both the instance security group and the load balancer use the region's default VPC. An account without one, or with fewer than two default subnets, cannot apply. This project does not create a VPC.
- **Public IPs.** Instances rely on the default subnets' auto-assign public IP setting for SSH and for outbound `git`/`npm`. The launch template does not set `associate_public_ip_address`, because that argument conflicts with `vpc_security_group_ids` unless you move the security groups onto a `network_interfaces` block.
- **Open ports are intentional.** SSH (`ssh_cidr_blocks`) and the dev server port (`app_cidr_blocks`) default to `0.0.0.0/0`. The load balancer module is applied after the instance security group, so the instance rule cannot reference the load balancer's security group without a cycle or a module merge. Tighten the CIDRs in tfvars instead of merging the modules.
- **Health checks.** The group uses ELB health, not the EC2 default. EC2 checks stay green when `npm run dev` never listens. `health_check_grace_period` (default 900) and `wait_for_capacity_timeout = "0"` keep apply from failing or replacing instances during install. `test.sh` is the readiness check.
- **Launch template rollouts.** The Auto Scaling group pins `latest_version`, not `"$Latest"`. `"$Latest"` does not trigger instance refresh. User-data or AMI changes roll instances. Expect that on the next apply a human runs.
- **State holds an SSH private key.** `tls_private_key.ssh` puts the PEM in state. The state bucket blocks public access for that reason. Never write the key into the repo. The Ubuntu SSH user is `ubuntu`, not `root` or `ec2-user`.
- **Node and the dev script.** Instances install the Node version in `node_version` (default 24.22.0). `NODE_ENV` is unset during `npm install` so devDependencies install. The process must listen on `0.0.0.0` and `server_port`. Setting `PORT` does not rewrite an npm script that hardcodes a port.
- **The 2016 ReactCalculator snapshot is not a supported target.** webpack 1 will not run on Node 24. The default `repo_name` is kept so the original example is still the documented repository name.
- **S3 names from the original commit are gone.** `terraform-remote-state-pranav` and `terraform-locks-pranav` are not referenced. DynamoDB locking is deprecated; do not add the table back. Use `use_lockfile`.
- **`prevent_destroy` on the state bucket** makes `terraform destroy` in `bootstrap/` fail until that block is removed. That is deliberate.
- **AMI filter.** `ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*`, owner `099720109477`. `instance_type` must be x86_64. `most_recent = true` means a later apply can roll instances onto a newer Ubuntu image. That is what you want for a dev box and is noisy in a long-lived one.
- **No scaling policy.** Desired capacity is `min_size`. `max_size` does not launch extra instances by itself.
- **Renames.** Security group, load balancer, and target group names are stable strings derived from `name_slug`. Changing `repo_name` forces replacement and can collide on the old name for one apply. Launch templates and key pairs use `name_prefix` plus `create_before_destroy` so a rotation can overlap.

## Changing the boot script

`modules/launch_template/user-data.sh` is a `templatefile()` template. The application root's partial S3 backend refuses `terraform console` until `backend.hcl` exists. Render the script without AWS from a throwaway directory that has no backend:

```bash
mkdir -p /tmp/render-ud
printf '%s\n' 'terraform { required_version = ">= 1.16.0" }' > /tmp/render-ud/versions.tf
terraform -chdir=/tmp/render-ud init -input=false
terraform -chdir=/tmp/render-ud console
```

At the prompt, evaluate one line:

```text
templatefile("/absolute/path/to/modules/launch_template/user-data.sh", { github_owner = "pranavprem", repo_name = "ReactCalculator", server_port = 8080, node_version = "24.22.0" })
```

Check the rendered file with `bash -n`. The module calls `templatefile("${path.module}/user-data.sh", ...)`. Do not `terraform apply` to test the script.
