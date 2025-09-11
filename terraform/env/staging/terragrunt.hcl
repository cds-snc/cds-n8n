terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.110.1@sha256:6c0c7650150a3fb0fd30d13160a87b5227963c36c9297b5bda618bcadfcee932"
  model_container_image = "ollama/ollama:0.11.9@sha256:d8f430f5b760c8c2f93d6fc12d91fa02dfb1ec3d55865483adb9b76c43b0e980"
}