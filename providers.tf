# providers.tf
terraform {
  required_providers {
    # http = {
    #   source  = "hashicorp/http"
    #   version = "3.4.1"
    # }
  }
}

provider "aws" {
  # region = "us-east-1"
}
