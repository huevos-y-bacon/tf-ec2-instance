# providers.tf
terraform {

  # Terraform 1.5.7 is the latest version of Terraform that uses MPL-2.0 license and is compatible with OpenTofu. Opentofu earliest version is 1.6.0
  required_version = "<= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.60.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.6.2"
    }

    http = {
      source  = "hashicorp/http"
      version = "~>3.4.3"
    }
  }
}

locals {
  # Helps locate the component
  provider_tf_component = "${basename(abspath("${path.module}/.."))}/${basename(abspath("${path.module}"))}"
  # provider_tf_component = "${basename(abspath("${path.module}/../.."))}/${basename(dirname(abspath(path.module)))}" # useful if in tf subfolder
  provider_component_tags = {
    "terraform:component" = local.provider_tf_component
  }
}

provider "aws" {
  # region = var.region
  # profile = "my_profile"

  default_tags { tags = local.provider_component_tags }
}
