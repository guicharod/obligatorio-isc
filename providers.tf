   # Versiones de Terraform y del provider de AWS usadas en el proyecto
   terraform {
     required_version = ">= 1.16.5" # la de Terraform, tal cual

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