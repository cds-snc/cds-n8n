terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.122.4@sha256:890c57b244dc8dd2688a05f70759f4b7792871f2a318395882908e751dfdc7f3"
  model_container_image = "ollama/ollama:0.13.1@sha256:8850b8b33936b9fb246e7b3e02849941f1151ea847e5fb15511f17de9589aea1"
}