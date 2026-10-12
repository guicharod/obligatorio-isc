# Versiones de Terraform y del provider de AWS
terraform {
  required_version = ">= 1.16.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.68"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}