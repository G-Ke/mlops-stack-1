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

resource "docker_image" "mlo2-image" {
  name = "mlo2:latest"
}

resource "docker_container" "mlo2-container" {
  image = docker_image.mlo2-image.image_id
  name  = "MLOps-2"
  ports {
    internal = 80
    external = 8000
  }
}