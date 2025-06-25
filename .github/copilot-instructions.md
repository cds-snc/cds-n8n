This project manages the AWS infrastructure for the n8n automation workflow service.

Respond to prompts concisely.  Only provide 1 sentence explanations at each stage including when the task is complete.

When writing Terraform use the latest available AWS v6 provider documentation as a reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

Terragrunt configurations in `./terraform/env/<environment>` manages different environments and a single root module defines all infrastructure in the `./terraform/aws/` directory.

All Terraform code should follow best practices for readability and maintainability.

Follow AWS best practices for infrastructure resilience and security.

Prioritize cost, security and NIST 800.53 revision 5 compliance when generating new Terraform code.

If new Terraform variables are added, ensure the appropriate terragrunt.hcl files are updated.  If the variable is sensitive update the `terraform.tfvars` files and Terraform plan and apply `env` blocks in the GitHub workflows: `.github/workflows/`.

Pin the version of `cds-snc/terraform-modules` to the latest available release's tag.

Pin the version of GitHub actions using the latest release's commit SHA.

Do not add comments to the generated code.

Once a task is completed, run `terraform fmt -recursive` in the `./terraform` directory.
