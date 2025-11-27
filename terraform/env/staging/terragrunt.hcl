terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.121.2@sha256:50f1b188e0398c409eab52a530cac79c5b477d1d30e8e972ed73935e5eaeacfd"
  model_container_image = "ollama/ollama:0.13.0@sha256:d4188c1dfa870386a14e299976aed96daeb83876b69e1a852c9d09ea76463b9f"
}