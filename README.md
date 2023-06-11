# mlops-stack-1

This is a work in progress. The goal is to deploy ML models using FastAPI, Docker, and Terraform.

## Process Notes

1. Build Docker image: `docker build --tag mlops-1:latest .`
2. Use Terraform to Build and run Docker container: `terraform plan` `terraform apply`
3. Rebuild Image: `docker build --tag mlops-1:latest .`
4. Re-Run Apply etc: `terraform apply`
5. Use Terraform to stop the Container: `terraform destroy`
