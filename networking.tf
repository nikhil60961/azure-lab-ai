resource "azurerm_virtual_network" "vnet" {
    name = "${local.prefix}-${var.workspace}-${var.environment}-vnet"
    resource_group_name = azurerm_resource_group.rg.name
    location = local.location

    address_space = [ 
        var.prvt_network_cidr 
    ]

    tags = {
        for key, value in local.default_tags: key => value
    }

    depends_on = [ azurerm_resource_group.rg ]
}


resource "azurerm_subnet" "subnet" {
    name = "${local.prefix}-${var.workspace}-${var.environment}-subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name

    address_prefixes = [ 
        var.prvt_network_cidr 
    ]

    depends_on = [ 
        azurerm_resource_group.rg, 
        azurerm_virtual_network.vnet
        ]
}


resource azurerm_network_security_group "nsg" {
    name = "${local.prefix}-${var.workspace}-${var.environment}-nsg"
    resource_group_name = azurerm_resource_group.rg.name
    location = local.location
    
    tags = {
        for key, value in local.default_tags: key => value
    }

    depends_on = [ azurerm_resource_group.rg ]

}


resource azurerm_subnet_network_security_group_association "subnet-nsg-link" {
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
    
    depends_on = [ 
        azurerm_subnet.subnet, 
        azurerm_network_security_group.nsg
    ]
}


resource "azurerm_private_dns_zone" "aoai-privatedns" {
    name = "privatelink.openai.azure.com"
    resource_group_name = azurerm_resource_group.rg.name
    
    tags = {
        for key, value in local.default_tags: key => value
    }

    depends_on = [ azurerm_resource_group.rg ]
}


resource "azurerm_private_dns_zone_virtual_network_link" "aoai-privatedns_vnet_link" {
    name = "${local.prefix}-${var.workspace}-${var.environment}-privatedns-vnet-link"
    resource_group_name = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.aoai-privatedns.name
    virtual_network_id = azurerm_virtual_network.vnet.id

    tags = {
        for key, value in local.default_tags : key => value
    }

    depends_on = [ 
        azurerm_resource_group.rg, 
        azurerm_private_dns_zone.aoai-privatedns, 
        azurerm_virtual_network.vnet
     ]
}
