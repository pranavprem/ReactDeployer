# ReactDeployer

ReactDeployer turns a public GitHub repository into a running React dev server on AWS.
It is a small, opinionated stack: a default VPC, an Auto Scaling group, and an
Application Load Balancer. Each instance clones the repository and runs `npm run dev`.

The project started as a way to practice the first chapters of *Terraform: Up and Running*. The shape is the same. The Terraform, the AWS resources, and the boot script have been brought forward so they work with current releases.

## How it works

Two Terraform roots share the modules under `modules/`. They are separate because the state bucket has to exist before the application stack can store its state there.

```text
bootstrap/                         application stack (repo root)
  creates the S3 state bucket  -->   stores its state in that bucket
                                     creates the app infrastructure
```

On apply, the application stack does four things:

1. Looks up the default VPC and its default subnets in `aws_region`.
2. Builds a launch template that installs Node.js, clones `github_owner/repo_name`, and starts `npm run dev` under systemd.
3. Places a minimum of `min_size` instances (default 2) behind an internet-facing load balancer.
4. Forwards HTTP on port 80 to the dev server port (default 8080).

```text
you --HTTP:80--> Application Load Balancer --> instances:8080
                                              |
                                              +--> git clone https://github.com/<owner>/<repo>
                                              +--> npm install && npm run dev
```

Apply returns when the instances and load balancer exist. It does not wait for `npm install`. `test.sh` polls the load balancer for up to 15 minutes, which matches the default health-check grace period.

## How to use it today

You need:

- Terraform 1.16 (this repo was checked with 1.16.6)
- AWS credentials with permission to manage EC2, Auto Scaling, ELB, and S3
- A default VPC in the chosen region, with at least two default subnets
- A **public** GitHub repository whose `dev` script listens on `0.0.0.0` and `server_port`

The repository's package script has to bind the port itself. `HOST` and `PORT` are set in the systemd unit for tools that honor them (Create React App does; many others do not). A script that works with the defaults looks like:

```json
"dev": "vite --host 0.0.0.0 --port 8080"
```

The historical `ReactCalculator` commit this repo was written against uses webpack 1 and React 0.14.
That app matches the old contract (`--host 0.0.0.0`, webpack-dev-server's default port 8080),
and it will not install or run on the Node.js 24 LTS these instances install.
Point `repo_name` at a repository that runs on current Node.

### 1. Create the state bucket

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# Set bucket_name to a globally unique name you own.
terraform init
terraform apply
terraform output -raw backend_hcl > ../backend.hcl
cd ..
```

`bootstrap/terraform.tfstate` stays on your machine. It is gitignored. Do not delete it while the bucket still exists: it is how Terraform knows the bucket it created.

### 2. Deploy the application

```bash
cp terraform.tfvars.example terraform.tfvars   # optional; the defaults match the examples
terraform init -backend-config=backend.hcl
terraform apply
./test.sh
```

`backend.hcl` and `terraform.tfvars` are gitignored. `backend.hcl.example` shows the shape. Locking uses an S3 lock file (`use_lockfile = true`), which is the current S3 backend. The bucket is versioned, encrypted, and blocks public access.

### 3. SSH, when something does not boot

The private key is a sensitive output, and it lives in the state file:

```bash
terraform output -raw private_key_pem > "$HOME/react-deployer.pem"
chmod 600 "$HOME/react-deployer.pem"
```

The Ubuntu account is `ubuntu`. Instance addresses are in the EC2 console; the Auto Scaling group does not publish them as outputs. On the instance:

```bash
sudo journalctl -u react-dev
sudo less /var/log/react-deploy-bootstrap.log
```

### 4. Destroy

Destroy the application stack first (`terraform destroy` from the repo root). That removes the load balancer, the group, and the instances.

The state bucket is protected with `prevent_destroy`.
`terraform destroy` in `bootstrap/` will refuse to delete it.
Empty the bucket, including old versions, and remove that lifecycle block only when you actually want the bucket gone.
Leaving it in place is the normal end state.

## Stack

| Piece | Choice |
| --- | --- |
| Terraform | 1.16.x, lockfile committed (checked with 1.16.6) |
| AWS provider | 6.69.x |
| TLS provider | 4.4.x, used only to generate the SSH key |
| Compute | Ubuntu 26.04 LTS (Canonical, amd64), `t3.micro` by default |
| Node.js | 24.22.0 LTS, verified against the published checksum |
| Network | Default VPC, public Application Load Balancer, HTTP only |
| State | S3 bucket with versioning, SSE-S3, and native S3 locking |

## Repository structure

```text
.
├── main.tf                  provider
├── versions.tf              Terraform, providers, partial S3 backend
├── variables.tf             region, repository, size, ports
├── locals.tf                name_slug shared by both app modules
├── launch_template.tf       module call
├── autoscaling.tf           module call
├── outputs.tf
├── backend.hcl.example
├── terraform.tfvars.example
├── test.sh
├── bootstrap/               separate root; creates the state bucket
└── modules/
    ├── backend/             bucket, versioning, encryption, public-access block
    ├── launch_template/     AMI, key, security group, user-data
    └── autoscaling_loadbalancing/
```

Changing a module input from the root is the supported way to configure a deployment. The modules do not read `terraform.tfvars` themselves.

## Cost

An internet-facing Application Load Balancer is billed for every hour it exists,
and the group launches `min_size` instances (2 by default) until you destroy the stack.
`max_size` is only a ceiling. Nothing in this configuration raises the desired capacity on its own.

## What this does not do

There is no HTTPS, no custom domain, no custom VPC, and no production build step.
The dev server is the process behind the load balancer.
Private GitHub repositories are not supported. Terratest is not wired up.
A backend for the React app itself is out of scope; this deploys the front-end dev server only.
