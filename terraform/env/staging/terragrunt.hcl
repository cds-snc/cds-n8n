terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.110.1@sha256:6c0c7650150a3fb0fd30d13160a87b5227963c36c9297b5bda618bcadfcee932"
  model_container_image = "ollama/ollama:0.9.3@sha256:45008241d61056449dd4f20cebf64bfa5a2168b0c078ecf34aa2779760502c2f"
}