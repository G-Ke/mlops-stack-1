terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
}

resource "docker_image" "mlops-image-1" {
  name = "mlops-1:latest"
  keep_locally = true
}

resource "docker_container" "mlops-container-1" {
  image = docker_image.mlops-image-1.image_id
  name  = "MLOps-1"
  ports {
    internal = 80
    external = 8000
  }
}