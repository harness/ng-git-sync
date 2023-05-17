module "organization" {
  source = "../terraform-harness-structure/modules/organizations"

  name     = var.organization_name
  existing = true
}

module "project" {
  source = "../terraform-harness-structure/modules/projects"

  name            = var.project_name
  organization_id = module.organization.details.id
}

module "services" {
  depends_on = [
    module.project
  ]
  source = "../terraform-harness-delivery/modules/services"

  for_each = {
    for service in local.services : service.name => service
  }

  identifier      = lookup(each.value, "identifier", null)
  name            = each.value.name
  organization_id = module.organization.details.id
  project_id      = module.project.details.id
  yaml_data       = <<EOT
    ${indent(4, yamlencode({ serviceDefinition = each.value.serviceDefinition }))}
  EOT

}

module "templates" {
  depends_on = [
    module.project
  ]
  source = "../terraform-harness-content/modules/templates"

  for_each = {
    for template in local.templates : template.name => template
  }

  identifier       = lookup(each.value, "identifier", null)
  name             = each.value.name
  type             = each.value.type
  template_version = each.value.versionLabel
  organization_id  = module.organization.details.id
  project_id       = module.project.details.id
  yaml_data        = <<EOT
    ${indent(4, yamlencode({ spec = each.value.spec }))}
  EOT

}

module "pipelines" {
  depends_on = [
    module.project,
    module.templates
  ]
  source = "../terraform-harness-content/modules/pipelines"

  for_each = {
    for pipeline in local.pipelines : pipeline.name => pipeline
  }

  identifier      = lookup(each.value, "identifier", null)
  name            = each.value.name
  organization_id = module.organization.details.id
  project_id      = module.project.details.id
  yaml_data       = <<EOT
    ${indent(4, yamlencode({ stages = each.value.stages }))}
  EOT

}

module "inputsets" {
  depends_on = [
    module.pipelines,
  ]
  source = "../terraform-harness-content/modules/input_sets"

  for_each = {
    for input_set in local.input_sets : input_set.name => input_set
  }

  identifier      = lookup(each.value, "identifier", null)
  name            = each.value.name
  organization_id = module.organization.details.id
  project_id      = module.project.details.id
  pipeline_id     = each.value.pipeline.identifier
  yaml_data       = <<EOT
    ${indent(4, yamlencode({ stages = each.value.pipeline.stages }))}
  EOT
}

module "triggers" {
  depends_on = [
    module.pipelines,
  ]
  source = "../terraform-harness-content/modules/triggers"

  for_each = {
    for trigger in local.triggers : trigger.name => trigger
  }

  identifier      = lookup(each.value, "identifier", null)
  name            = each.value.name
  organization_id = module.organization.details.id
  project_id      = module.project.details.id
  pipeline_id     = each.value.pipelineIdentifier
  yaml_data       = <<EOT
    ${indent(4, yamlencode({ source = each.value.source }))}
    ${indent(4, yamlencode({ inputYaml = each.value.inputYaml }))}
  EOT

}

module "environments" {
  # depends_on = [
  #   module.services
  # ]
  source = "../terraform-harness-delivery/modules/environments"

  for_each = {
    for environment in local.environments : environment.name => environment
  }

  identifier      = lookup(each.value, "identifier", null)
  name            = each.value.name
  organization_id = module.organization.details.id
  project_id      = module.project.details.id
  type            = lookup(local.environment_types, each.value.type, "nonprod")
  yaml_data       = <<EOT
    ${indent(4, yamlencode({ variables = each.value.variables }))}
  EOT
}

module "service_overrides" {
  depends_on = [
    module.services,
    module.environments
  ]
  source = "../terraform-harness-delivery/modules/environment_service_overrides"

  for_each = {
    for service_override in local.service_overrides : service_override.name => service_override
  }

  identifier      = lookup(each.value, "identifier", null)
  name            = each.value.name
  organization_id = module.organization.details.id
  project_id      = module.project.details.id
  environment_id  = each.value.environmentRef
  service_id      = each.value.serviceRef
  yaml_data       = <<EOT
    ${indent(4, yamlencode({ variables = each.value.variables }))}
    ${indent(4, yamlencode({ manifests = each.value.manifests }))}
    ${indent(4, yamlencode({ configFiles = each.value.configFiles }))}
  EOT
}

module "infrastructures" {
  depends_on = [
    module.environments
  ]
  source = "../terraform-harness-delivery/modules/infrastructures"

  for_each = {
    for infrastructure in local.infrastructures : "${infrastructure.environment_name}/${infrastructure.name}" => infrastructure
  }

  identifier      = lookup(each.value, "identifier", null)
  name            = each.value.name
  organization_id = module.organization.details.id
  project_id      = module.project.details.id
  environment_id  = module.environments[each.value.environment_name].environment_details.id
  type            = each.value.type
  deployment_type = each.value.deploymentType
  yaml_data       = <<EOT
    ${indent(4, yamlencode({ spec = each.value.spec }))}
  EOT
}
