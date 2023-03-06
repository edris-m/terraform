include {
  path = "${find_in_parent_folders()}"
}
terraform {
  source = "."

  extra_arguments "conditional_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]

    optional_var_files = [
      "${get_terragrunt_dir()}/../../../region.tfvars",
      "${get_terragrunt_dir()}/custom.tfvars",
    ]
  }
}
