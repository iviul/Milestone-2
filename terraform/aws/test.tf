# variable "config" {
#   default = {
#     databases = [
#       {
#         name            = "main-db"
#         network         = "main"
#         type            = "postgres"
#         version         = "14"
#         size            = "small"
#         zone            = ["b", "c"]
#         subnet          = "private-subnet"
#         port            = 5432
#         security_groups = ["db-sg"]

#         #   subnets = [
#         #   {
#         #     name = "public-subnet",
#         #     cidr = "10.0.1.0/24",
#         #     public =  true,
#         #     zone = "a"
#         #   },
#         #   {
#         #     name = "private-subnet",
#         #     cidr = "10.0.2.0/24",
#         #     public =  false,
#         #     zone = "b"
#         #   },
#         # ]
#       },
#       {
#         name            = "main-db2"
#         network         = "main"
#         type            = "postgres"
#         version         = "14"
#         size            = "medium"
#         zone            = ["a", "b"]
#         subnet          = "private-subnet"
#         port            = 5432
#         security_groups = ["db-sg"]
#       }
#     ]
#   }
# }

# locals {
#   dbs = { for db in var.config.databases : db.name => {
#     # DB conf
#     identifier             = db.name
#     engine                 = db.type
#     port                   = db.port
#     allocated_storage      = local.size_map.aws[db.size].storage
#     instance_class         = local.size_map.aws[db.size].instance_class
#     availability_zone      = db.zone
#     vpc_security_group_ids = db.security_groups
#     tags                   = { Name : db.name }
#     }
#   }

#   # fixed_region_map = {
#   #   aws = "eu-central-1"
#   #   gcp = "europe-west3"
#   # }

#   # size_map = {
#   #   aws = {
#   #     small = {
#   #       storage        = 20
#   #       instance_class = "db.t4g.micro"
#   #     }
#   #     medium = {
#   #       storage        = 30
#   #       instance_class = "db.t4g.micro"
#   #     }
#   #     large = {
#   #       storage        = 40
#   #       instance_class = "db.t4g.micro"
#   #     }
#   #   }
#   # }

#   # subnets = merge([
#   #   for vpc_key, vpc in local.vpcs : {
#   #     for subnet in vpc.subnets :
#   #     "${vpc_key}-${subnet.name}" => {
#   #       vpc_id            = vpc_key
#   #       cidr_block        = subnet.cidr
#   #       availability_zone = "${local.fixed_region_map.aws}${subnet.zone}"
#   #       is_public         = subnet.public
#   #     }
#   #   }
#   # ]...)
# }
