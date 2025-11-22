terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.120.3@sha256:e047444709aa5ce8e2be7c952b51d95c35989ea8a36ed7b4ed478c2193df5825"
  model_container_image = "ollama/ollama:0.12.10@sha256:e8c3d1f6ad16323bc40dc63eff0701d4fc32113f75a86b54b3e836eef8290de6"
}