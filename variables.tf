# Provider Setup Details
# variable "harness_platform_url" {
#   type        = string
#   description = "[Optional] Enter the Harness Platform URL.  Defaults to Harness SaaS URL"
#   default     = "https://app.harness.io/gateway"
# }

# variable "harness_platform_account" {
#   type        = string
#   description = "[Required] Enter the Harness Platform Account Number"
#   sensitive   = true
# }

# variable "harness_platform_key" {
#   type        = string
#   description = "[Required] Enter the Harness Platform API Key for your account"
#   sensitive   = true
# }

variable "global_tags" {
  type        = map(any)
  description = "[Optional] Provide a Map of Tags to associate with all organizations and resources create"
  default     = {}
}

variable "organization_name" {
  type        = string
  description = "[Required] Enter the name of the Organization to create"
}

variable "create_organization" {
  type        = bool
  description = "[Optional] Should this execution create a new Organization"
  default     = false
}

variable "project_name" {
  type        = string
  description = "[Required] Enter the name of the Project to create"
}

variable "content_library" {
  type        = string
  description = "[Required] Enter the absolute path to the content library"
  default     = null
}
