

resource "azurerm_storage_account" "storage" {
  name                     = "nikhil609651aifoundary"
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "example" {
  name                  = "tfstate-aifoundry-dev"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}