# Terraform Setup
terraform {
  required_providers {
    /*
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
      configuration_aliases = [ aws.alternate ]
    }
    */

    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}


# Added GitHub Actions to workflow.

terraform {
  cloud {

    organization = "statuc_devops"

    workspaces {
      name = "armageddon-github-actions"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

