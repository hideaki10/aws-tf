# Terraform AWS Infrastructure

This repository contains Terraform configurations for managing AWS infrastructure resources.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version specified in `version.tf`)
- AWS CLI configured with appropriate credentials
- S3 bucket and DynamoDB table for remote state (already configured)

## Remote State Configuration

This project uses an S3 bucket for storing the Terraform state remotely and DynamoDB for state locking:

- **S3 Bucket**: `terraform-remote-state-demo-20250418-tokyo`
- **DynamoDB Table**: `terraform-remote-state-demo-20250418-tokyo`
- **Region**: `ap-northeast-1` (Tokyo)

## Project Structure

```
aws-tf/
├── .gitignore           # Git ignore file
├── README.md            # This file
├── backend.tf           # Remote state configuration
├── version.tf           # Terraform version constraints
└── modules/             # Reusable module definitions
```

## Getting Started

1. **Initialize Terraform**:
   ```
   terraform init
   ```

2. **Plan your changes**:
   ```
   terraform plan
   ```

3. **Apply the changes**:
   ```
   terraform apply
   ```

## Best Practices

- Always run `terraform plan` before applying changes
- Use workspaces for managing multiple environments
- Keep sensitive data in `.tfvars` files (excluded from git)
- Use modules for reusable components

## Security Notes

- Never commit `.tfstate` files or `.terraform` directories to version control
- Ensure AWS credentials are not hardcoded in any Terraform files
- Use IAM roles with least privilege principle

## License

[Specify your license here] 