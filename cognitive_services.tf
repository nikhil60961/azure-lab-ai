

locals {
    cognitive_accounts_list = flatten( [ for region in keys(local.az_region_models) : 
                                            [ for intent in local.service_intents : 
                                                {   "region" = region, 
                                                    "intent" = intent
                                                    "public" = intent == "studio" ? true : false
                                                    # "network_acls" = intent == "studio" ? object({ default_action = "Deny", ip_rules = local.allowed_networks }) : object({ default_actioni = "Deny", ip_rules = [] })
                                                }
                                            ] 
                                        ] 
                                    )
    cognitive_accounts_map = { for index, ca in local.cognitive_accounts_list : 
                                    index => ca
                             }  # for_each requires a map, or a list of strings; the above list of maps does not work
}


resource azurerm_cognitive_account "accounts" {

    for_each = local.cognitive_accounts_map

    # name = "${local.prefix}-${each.value.intent}-${each.value.region}-${random_pet.pet_name.id}"
    name = "${local.prefix}-${var.workspace}-${var.environment}-${each.value.intent}-${each.value.region}"
    resource_group_name = azurerm_resource_group.rg.name
    location = "${each.value.region}"

    kind = "OpenAI"

    sku_name = "S0"
    custom_subdomain_name = "${local.prefix}-${var.workspace}-${var.environment}-${each.value.intent}-${each.value.region}"
   
    # public_network_access_enabled = tobool("${each.value.public}")
    public_network_access_enabled = false

    network_acls { 
        default_action = "Deny"
        # ip_rules = local.allowed_networks
        ip_rules = [ ]
    }

    identity {
        type = "SystemAssigned"
    }

    tags = {
        for key, value in local.default_tags : key => value
    }
    
    depends_on = [ 
        azurerm_resource_group.rg, 
        random_pet.pet_name ]
}


resource "azurerm_private_endpoint" "aoaiplay-aoai-pe" {
    # Add private endpoint only for studio cognitive accounts
    
    for_each = { for index, account in azurerm_cognitive_account.accounts : 
                    index => account if account.public_network_access_enabled == false }
    
    name = "${each.value.name}-pe"
    resource_group_name = azurerm_resource_group.rg.name

    # private endpoint must be in the same region and subscription as the VNet; target resource can be in a different region
    # https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-endpoint-properties
    location = azurerm_virtual_network.vnet.location
        
    subnet_id = azurerm_subnet.subnet.id
    
    private_service_connection {
        name = "${each.value.name}-pe-service-connection"
        private_connection_resource_id = each.value.id
        subresource_names = [ "account" ]
        is_manual_connection = false
        }

    ip_configuration {
        name = "${each.value.name}-pe-ip-config"
        private_ip_address = cidrhost(azurerm_subnet.subnet.address_prefixes[0], each.key+4)    # 1st 4 IPs in subnet are reserved; each.key starts from 1??
        subresource_name = "account"
        member_name = "default"
    }

    private_dns_zone_group {
        name = "${local.prefix}-${var.workspace}-${var.environment}-dnszonegroup"
        private_dns_zone_ids = [ azurerm_private_dns_zone.aoai-privatedns.id ]
    }

    tags = {
        for key, value in local.default_tags: key => value
    }

    depends_on = [ 
        azurerm_resource_group.rg,
        azurerm_subnet.subnet,
        azurerm_private_dns_zone.aoai-privatedns,
        azurerm_cognitive_account.accounts
        ]
}


locals {

    cognitive_deployments_list = flatten([ for ca in azurerm_cognitive_account.accounts : 
                                              [ for model in local.az_region_models[ca.location] : 
                                                    { 
                                                        ca_id = ca.id, 
                                                        name = model["name"], 
                                                        version = model["version"], 
                                                        tokens_per_min_k = model["tokens_per_min_k"]
                                                    }
                                                ]
                                        ])

    cognitive_deployments_map = { for index, cd in local.cognitive_deployments_list :
                                    index => cd
                                }
}


resource "azurerm_cognitive_deployment" "deployments" {
    
    for_each = local.cognitive_deployments_map

    name = "${each.value.name}-${each.value.version}" 
    cognitive_account_id = "${each.value.ca_id}"
    
    model {
        format  = "OpenAI"
        name    = "${each.value.name}"
        version = "${each.value.version}"
    }

    version_upgrade_option = "NoAutoUpgrade"

    scale {
        type = "Standard"
        capacity = "${each.value.tokens_per_min_k}"
    }

    depends_on = [ azurerm_cognitive_account.accounts ] 
}
