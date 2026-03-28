# FlowIQ — Staging environment Terraform variable values
# Sensitive values (db_password, acm_certificate_arn) must be provided via:
#   - TF_VAR_db_password environment variable
#   - TF_VAR_acm_certificate_arn environment variable
#   - Or a terraform.tfvars.local file (gitignored)

aws_region = "ap-southeast-2"

vpc_cidr             = "10.0.0.0/16"
azs                  = ["ap-southeast-2a", "ap-southeast-2b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

rds_instance_class = "db.t3.medium"
db_name            = "flowiq"
db_username        = "flowiq_admin"

redis_node_type = "cache.t3.micro"

# acm_certificate_arn = "arn:aws:acm:ap-southeast-2:ACCOUNT_ID:certificate/..."
# db_password         = set via TF_VAR_db_password
