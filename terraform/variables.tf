variable "organization" {
  type        = string
  default     = "g-ke"
  description = "TF Cloud Organization Name"
}

variable "workspace" {
  type        = string
  default     = "mlops-stack-1"
  description = "TF Cloud Workspace Name"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "tag_value" {
  type        = string
  default     = "MLOps-Stack"
  description = "Tag Value"
}

variable "tag_key" {
  type        = string
  default     = "Project"
  description = "Tag Key"
}

variable "ecr_image" {
  type        = string
  default     = ""
  description = "ECR Image"
}