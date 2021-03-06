locals {
  repositories = [
    format("%s-ecr", local.project, ), # todo rename into tokenizer
  ]
}

resource "aws_ecr_repository" "main" {
  count = length(local.repositories)
  name  = local.repositories[count.index]

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = { "Name" : local.repositories[count.index] }

}

resource "aws_ecr_lifecycle_policy" "main" {
  count      = length(local.repositories)
  repository = aws_ecr_repository.main[count.index].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = format("Keeps last %s images", var.ecr_keep_nr_images)
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_keep_nr_images
      }
    }]
  })
}