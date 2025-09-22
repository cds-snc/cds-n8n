terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.111.0@sha256:8c99deed73dbb7f7b32c49f328015fe8322129a9dcf0459a10c4398af255083f"
  model_container_image = "ollama/ollama:0.11.10@sha256:a5409cb903d30f9cd67e9f430dd336ddc9274e16fd78f75b675c42065991b4fd"
}