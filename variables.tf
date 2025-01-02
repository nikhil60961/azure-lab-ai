
variable "workspace" {
    type = string
    description = "Name of the workspace. This value is set to 'global' for the global shared AOAI stack. For team / project-specific deployments, use a different name, for ex tov for the TOV team."
}


variable "environment" {
    type = string
    description = "Deployment environment name."
    
    validation {
      condition = contains(["dev", "prod"], var.environment)
      error_message = "The environment must be one of 'dev', or 'prod'."
    }
}


variable "subscription_id" {
    type = string
    description = "Target subscription to deploy resources."
}


variable "client_id" {
    type = string
    description = "Client id authorized to deploy azure resources in the target subscription."
}


variable "prvt_network_cidr" {
  type = string
  description = "VNet network address space in CIDR notation."
}
