terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.123.3@sha256:0fe24e854c030088695e4e75afda4d86e52814bb10268968bacd9880c0986862"
  model_container_image = "ollama/ollama:0.13.0@sha256:d4188c1dfa870386a14e299976aed96daeb83876b69e1a852c9d09ea76463b9f"
}