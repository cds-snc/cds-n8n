terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.123.4@sha256:d9162b9b151744f909d7e687f4179a1aa4e7f3a7504d6bf7e0c0e27852fe9731"
  model_container_image = "ollama/ollama:0.13.1@sha256:8850b8b33936b9fb246e7b3e02849941f1151ea847e5fb15511f17de9589aea1"
}