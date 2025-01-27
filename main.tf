resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = "nikhil609651aifoundary"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "example" {
  name                  = "tfstate-aifoundry-dev"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}