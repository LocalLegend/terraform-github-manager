data "github_user" "reviewer" {
  username = var.reviewer_username
}

resource "github_repository" "self" {
  name         = var.repo.name
  description  = var.repo.description
  homepage_url = var.homepage_url

  allow_merge_commit      = true
  delete_branch_on_merge  = true
}


resource "github_repository_collaborator" "collaborators" {
  for_each   = { for collab in var.collabs: "${var.repo.name}_${collab.username}" => collab }

  repository = github_repository.self.name
  username   = each.value.username
  permission = each.value.permission
}


resource "github_actions_secret" "secrets" {
  for_each   = { for secret in var.secrets: "${var.repo.name}_${secret.name}" => secret }

  repository       = github_repository.self.name
  secret_name      = each.value.name
  plaintext_value  = each.value.value
}


# Create dev environment
resource "github_repository_environment" "dev" {
  count = length(var.secrets_dev) == 0 ? 0 : 1
  environment  = "development"
  repository   = github_repository.self.name
}


# Create dev envs
resource "github_actions_environment_secret" "secrets_dev" {
  for_each        = { for secret in var.secrets_dev : "${var.repo.name}_${secret.name}" => secret }

  repository        = github_repository.self.name
  environment       = github_repository_environment.dev[0].environment
  secret_name       = each.value.name
  plaintext_value   = each.value.value

  depends_on = [
    github_repository_environment.dev[0]
  ]

}



resource "github_repository_environment" "prod" {
  environment  = "production"
  count = length(var.secrets_prod) == 0 ? 0 : 1
  repository   = github_repository.self.name
  reviewers {
    users = [data.github_user.current.id]
  }
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = false
  }
}

resource "github_actions_environment_secret" "secrets_prod" {
  for_each        = { for secret in var.secrets_prod : "${var.repo.name}_${secret.name}" => secret }

  environment       = github_repository_environment.prod[0].environment
  repository        = github_repository.self.name
  secret_name       = each.value.name
  plaintext_value   = each.value.value


  depends_on = [
    github_repository_environment.prod
  ]
}