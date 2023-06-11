# mlops-stack-1

This is a work in progress. The goal is to deploy ML models using FastAPI, Docker, and Terraform.

## Process Notes

1. Build Docker image: `docker build --tag mlops-1:latest .`
2. Use Terraform to Build and run Docker container: `terraform plan` `terraform apply`
3. Use Terraform to remove Container: `terraform destroy`
4. Rebuild Image: `docker build --tag mlops-1:latest .`
