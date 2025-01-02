# NOTE: this is for easier iteration of create/destroy. The domain names generated
# are soft deleted for 2 days and create naming conflicts
resource "random_pet" "pet_name" {
  length           = 2
}


resource "azurerm_resource_group" "rg" {
    name     = "${local.prefix}-${var.workspace}-${var.environment}"
    location = "${local.location}"

    tags = {
      for key, value in local.default_tags : key => value
    }
}
