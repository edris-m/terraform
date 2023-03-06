cluster_name  = "green_cluster"

vpc_id    = "vpc_id"

subnet_ids  = ["",""]

minimum = 3
maximum = 400
desired = 5

instance  = ["c6i.2xlarge"]

disk_size = "80"

subnets   = [""]

ssh_key = "key-pair-name"

auth_roles  = [
  {
    rolearn = "arn:aws:iam::ACCOUNT:role/roleNmae"
    username = "roleName"
    groups   = ["roleName"]
  },
  {
    rolearn = "arn:aws:iam::ACCOUNT:role/roleNmae"
    username = "roleName"
    groups   = ["roleName"]
  },
]

environment = "production"
