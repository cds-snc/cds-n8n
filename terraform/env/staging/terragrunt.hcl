terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.99.1@sha256:2537366a01590c499a4f2c9006da55cdda4c572fd2765a99f5687187ae1cd4be"
  model_container_image = "ollama/ollama:0.9.3@sha256:45008241d61056449dd4f20cebf64bfa5a2168b0c078ecf34aa2779760502c2f"
}