

locals {
    prefix = "aoai"
    location = "eastus2"

    default_tags = {
        env = "${var.environment}"
    }

    service_intents = ["studio", "api"]

    # NOTE: for dynamic capacity, check if this PR has been merged:
    # https://github.com/hashicorp/terraform-provider-azurerm/pull/25401
    az_region_models = {
        "eastus" = [
            {name = "gpt-4o", version = "2024-05-13", tokens_per_min_k=20},
            {name = "gpt-4o-mini", version = "2024-07-18", tokens_per_min_k=150},
            {name = "gpt-4", version = "turbo-2024-04-09", tokens_per_min_k=2},
            {name = "gpt-35-turbo", version = "0613", tokens_per_min_k=5},
            {name = "gpt-35-turbo-16k", version = "0613", tokens_per_min_k=5},
            {name = "text-embedding-3-large", version = "1", tokens_per_min_k=2},
            {name = "text-embedding-ada-002", version = "2", tokens_per_min_k=2},
        ],
        
        "eastus2" = [
            {name = "gpt-4o", version = "2024-05-13", tokens_per_min_k=20},
            {name = "gpt-4o-mini", version = "2024-07-18", tokens_per_min_k=150},
            {name = "gpt-4", version = "turbo-2024-04-09", tokens_per_min_k=2},
            {name = "gpt-35-turbo", version = "0613", tokens_per_min_k=5},
            {name = "gpt-35-turbo-16k", version = "0613", tokens_per_min_k=5},
            {name = "text-embedding-3-large", version = "1", tokens_per_min_k=2},
            {name = "text-embedding-ada-002", version = "2", tokens_per_min_k=2},
        ]}

    # For studio access
    allowed_networks = [
            "216.120.144.0/20",
            "216.165.112.0/20"
        ]
}
