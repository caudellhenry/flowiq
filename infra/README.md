# FlowIQ Infrastructure

Terraform configuration for the FlowIQ AWS infrastructure.

## Structure

```
infra/
├── modules/
│   ├── vpc/          # VPC, subnets, NAT gateway, route tables
│   ├── ecs/          # ECS Fargate cluster, ALB, task definitions, services
│   ├── rds/          # RDS PostgreSQL instance
│   ├── redis/        # ElastiCache Redis cluster
│   ├── s3/           # S3 documents bucket
│   ├── ecr/          # ECR repositories (one per service)
│   └── iam/          # ECS task roles + GitHub Actions deploy role
└── environments/
    └── staging/      # Staging environment wiring
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6
- AWS credentials configured (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` or IAM role)
- An ACM certificate ARN for the staging domain (or use a self-signed cert — see below)

## Staging deploy

```bash
cd infra/environments/staging

# 1. Export secrets
export TF_VAR_db_password="<strong-password>"
export TF_VAR_acm_certificate_arn="arn:aws:acm:ap-southeast-2:ACCOUNT_ID:certificate/..."

# 2. Init (downloads providers)
terraform init

# 3. Review the plan
terraform plan -out=staging.tfplan

# 4. Apply
terraform apply staging.tfplan
```

### ACM certificate

If you don't have a domain yet, request a certificate in ACM (us-east-1 for CloudFront, ap-southeast-2 for ALB) and validate it via DNS. Alternatively, create a self-signed cert and import it:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout staging.key -out staging.crt \
  -subj "/CN=staging.flowiq.internal"

aws acm import-certificate \
  --certificate fileb://staging.crt \
  --private-key fileb://staging.key \
  --region ap-southeast-2
```

## Outputs

After `terraform apply`, the following outputs are available:

| Output | Description |
|--------|-------------|
| `alb_dns_name` | ALB DNS — point your staging domain CNAME here |
| `rds_endpoint` | RDS PostgreSQL host:port |
| `redis_endpoint` | ElastiCache Redis host |
| `s3_documents_bucket` | S3 bucket name for document uploads |
| `ecr_repository_urls` | ECR repository URLs per service |
| `github_actions_deploy_role_arn` | IAM role for GitHub Actions OIDC |

Retrieve them anytime:

```bash
terraform output
```

## GitHub Actions OIDC setup

The IAM module creates a deploy role that GitHub Actions assumes via OIDC (no long-lived keys). After `apply`:

1. Copy the `github_actions_deploy_role_arn` output.
2. Add it as a GitHub Actions secret: `AWS_DEPLOY_ROLE_ARN`.
3. The CI/CD workflow (`/.github/workflows/deploy.yml`) uses this role automatically.

You may need to first create the OIDC provider in IAM if it doesn't exist:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

## Remote state (recommended)

Before team use, enable the S3 backend in `environments/staging/main.tf`. Create the bucket and DynamoDB table first:

```bash
aws s3api create-bucket \
  --bucket flowiq-terraform-state \
  --region ap-southeast-2 \
  --create-bucket-configuration LocationConstraint=ap-southeast-2

aws s3api put-bucket-versioning \
  --bucket flowiq-terraform-state \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name flowiq-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-southeast-2
```

Then uncomment the `backend "s3"` block in `environments/staging/main.tf` and run `terraform init -migrate-state`.

## Architecture

```
Internet
    │
    ▼
[ALB] (public subnets, HTTPS:443)
    │  path-based routing
    ├──/api/*──▶ [ECS: api]    (Node.js/Fastify, port 3000)
    ├──/ai/*───▶ [ECS: ai-svc] (Python/FastAPI, port 8000)
    └──default──▶ [ECS: web]   (Next.js, port 3001)
                     │
            [private subnets]
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
        [RDS]     [Redis]     [S3]
      PostgreSQL  ElastiCache  Documents
```
