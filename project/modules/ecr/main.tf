terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"
  //repository_force_delete = false
   # Name of the ECR repository

  repository_name = var.ecr_repo_name

 # Define a repository lifecycle policy to manage images
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

}
