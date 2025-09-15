terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.110.1@sha256:6c0c7650150a3fb0fd30d13160a87b5227963c36c9297b5bda618bcadfcee932"
  model_container_image = "ollama/ollama:0.11.10@sha256:a5409cb903d30f9cd67e9f430dd336ddc9274e16fd78f75b675c42065991b4fd"
}