terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.115.0@sha256:37b55505854e4f9ca840672c6e94abbe35cfba5fc63c750f2b3c470ca5529af4"
  model_container_image = "ollama/ollama:0.12.3@sha256:c622a7adec67cf5bd7fe1802b7e26aa583a955a54e91d132889301f50c3e0bd0"
}