resource "azurerm_public_ip" "example" {
  name                = "ai-${var.environment}"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"

  tags = {
    environment = "${var.environment}"
  }
}