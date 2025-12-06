terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.122.4@sha256:890c57b244dc8dd2688a05f70759f4b7792871f2a318395882908e751dfdc7f3"
  model_container_image = "ollama/ollama:0.13.0@sha256:d4188c1dfa870386a14e299976aed96daeb83876b69e1a852c9d09ea76463b9f"
}