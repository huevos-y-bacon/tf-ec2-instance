# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }

    # http = {
    #   source  = "hashicorp/http"
    #   version = "3.4.1"
    # }
  }
}

provider "aws" {
  # region = "us-east-1"
}
