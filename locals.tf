locals {
  environment_types = {
    PreProduction = "nonprod",
    Production    = "prod"
  }

  source_directory = var.content_library != null ? var.content_library : "../repo"

  environment_files_path = "${local.source_directory}/${var.organization_name}/${var.project_name}/Envs"
  service_files_path     = "${local.source_directory}/${var.organization_name}/${var.project_name}/Service"
  pipeline_files_path    = "${local.source_directory}/${var.organization_name}/${var.project_name}/Pipelines"
  template_files_path    = "${local.source_directory}/${var.organization_name}/${var.project_name}/Templates"
  trigger_files_path     = "${local.source_directory}/${var.organization_name}/${var.project_name}/Triggers"
  input_sets_files_path  = "${local.source_directory}/${var.organization_name}/${var.project_name}/InputSets"

  input_sets_files = fileset("${local.input_sets_files_path}/", "*.yaml")

  input_sets = flatten([
    for input_sets_file in local.input_sets_files : [
      merge(
        yamldecode(file("${local.input_sets_files_path}/${input_sets_file}"))["inputSet"],
        {
          name = replace(input_sets_file, ".yaml", "")

        }
      )
    ]
  ])

  environment_files = fileset("${local.environment_files_path}/", "**/env.yaml")

  environments = flatten([
    for environment_file in local.environment_files : [
      merge(
        yamldecode(file("${local.environment_files_path}/${environment_file}"))["environment"],
        {
          name = replace(environment_file, "/env.yaml", "")

        }
      )
    ]
  ])

  infrastructure_files = fileset("${local.environment_files_path}/", "**/*infraDef.yaml")

  infrastructures = flatten([
    for infrastructure_file in local.infrastructure_files : [
      merge(
        yamldecode(file("${local.environment_files_path}/${infrastructure_file}"))["infrastructureDefinition"],
        {
          name             = replace(split("/", infrastructure_file)[1], "-infraDef.yaml", "")
          environment_name = split("/", infrastructure_file)[0]
        }
      )
    ]
  ])

  service_files = fileset("${local.service_files_path}/", "*.yaml")

  services = flatten([
    for service_file in local.service_files : [
      merge(
        yamldecode(file("${local.service_files_path}/${service_file}"))["service"],
        {
          name = replace(service_file, ".yaml", "")
        }
      )
    ]
  ])

  trigger_files = fileset("${local.trigger_files_path}/", "*.yaml")

  triggers = flatten([
    for trigger_file in local.trigger_files : [
      merge(
        yamldecode(file("${local.trigger_files_path}/${trigger_file}"))["trigger"],
        {
          name = replace(trigger_file, ".yaml", "")
        }
      )
    ]
  ])

  template_files = fileset("${local.template_files_path}/", "*.yaml")

  templates = flatten([
    for template_file in local.template_files : [
      merge(
        yamldecode(file("${local.template_files_path}/${template_file}"))["template"],
        {
          name = replace(template_file, ".yaml", "")
        }
      )
    ]
  ])

  service_override_files = fileset("${local.environment_files_path}/", "**/service-overrides.yaml")

  service_overrides = flatten([
    for service_override_file in local.service_override_files : [
      merge(
        yamldecode(file("${local.environment_files_path}/${service_override_file}"))["serviceOverrides"],
        {
          name = replace(service_override_file, ".yaml", "")
        }
      )
    ]
  ])

  pipeline_files = fileset("${local.pipeline_files_path}/", "*.yaml")

  pipelines = flatten([
    for pipeline_file in local.pipeline_files : [
      merge(
        yamldecode(file("${local.pipeline_files_path}/${pipeline_file}"))["pipeline"],
        {
          name = replace(pipeline_file, ".yaml", "")
        }
      )
    ]
  ])
}
