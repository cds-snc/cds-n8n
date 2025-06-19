terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image = "n8nio/n8n:1.99.1@sha256:2537366a01590c499a4f2c9006da55cdda4c572fd2765a99f5687187ae1cd4be"
}