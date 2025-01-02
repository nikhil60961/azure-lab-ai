
terraform {
    required_version = ">= 1.1.0"
    
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>3.115.0"
        }

        random = {
            source  = "hashicorp/random"
            version = "~>3.0"
        }
    }

    backend azurerm {
        ## Configure directly in Azure DevOps pipeline (Terraform/init) task 
        
        # tenant_id = ""
        # subscription_id = ""
        # resource_group_name = ""
        # storage_account_name = ""
        # container_name = ""
        # key = ""                   # Set to "terraform-${var.workspace}.tfstate" for the stack, where workspace="shared" for the shared stack, "tov" for the TOV stack etc.
        # client_id = ""
        # client_secret = ""
        # use_azuread_auth = true
    }
}


provider "azurerm" {
    # Configuration options
    tenant_id = ""
    subscription_id = "${var.subscription_id}"
    client_id = "${var.client_id}"

    features {
    }
}
