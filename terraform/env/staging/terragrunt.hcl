terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.119.0@sha256:8f6834c399b5a764d5b0165db5d52d757652edb8f6b938b30b0cdf70fdfd3df1"
  model_container_image = "ollama/ollama:0.12.9@sha256:889ae74bdb4aa541044574d3e5e5dedde3c682c8b7918b6792aa031e7dfc8f06"
}