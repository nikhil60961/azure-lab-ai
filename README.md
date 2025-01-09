

Core features:  
1. remote tfstate management, also supporting workspaces for quick testing, replicating but without disrupting the base environments (dev, prod)
    - ALL backend config is stored in:
        - for Dev: nonprod/dev/dev.backend.hclb
        - for Prod: prod/prod.backend.hcl
    - ALL env-specific vars are stored in:w
        - for Dev: nonprod/dev/dev.tfvars
        - for Prod: prod/prod.tfvars
    - commands to runs:
        - Dev:
            ```bash
            export ARM_CLIENT_SECRET="<TERRAFORM_SP_SECRET>"
            terraform init -reconfigure -backend-config=nonprod/dev/dev.backend.hcl
            terraform apply -var-file=nonprod/dev/dev.tfvars
            ```

        - Prod:
            ```bash
            export ARM_CLIENT_SECRET="<TERRAFORM_SP_SECRET>"
            terraform init -reconfigure -backend-config=prod/prod.backend.hcl
            terraform apply -var-file=prod/prod.tfvars
            ```

2. add environment tag to all Azure resources created:
    - use local.default_tag local variable and a "for" expression to set the tags in each resource

3. A variable called "workspace" is used to isolate shared deployments from team / project-specific deployments. Value is set to "global" for the shared stack. Use appropriate values for projects and teams - for ex, workspace="tov" for the TOV team.
    - For each stack, the backend (remote tfstate blob filename) also changes. Set this "key" in respective backend config file. For ex, key = "terraform-global.tfstate" is set in both nonprod/dev/dev.backend.hcl and prod/prod.backend.hcl. For TOV deployment, set key = "terraform-tov.tfstate" to match the workspace name
