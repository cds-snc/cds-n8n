terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.104.2@sha256:4a475a6fdeb929f1070031d9ebfc49414d1e450886c6d000e5f6b432ebe4b8b6"
  model_container_image = "ollama/ollama:0.9.3@sha256:45008241d61056449dd4f20cebf64bfa5a2168b0c078ecf34aa2779760502c2f"
}