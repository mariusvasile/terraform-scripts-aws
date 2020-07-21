provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "latest_ecs" {
  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "test" {
  source                     = "./modules/test"
  team                       = "${var.team}"
  environment                = "${var.environment}"
  ami_id                     = "${data.aws_ami.latest_ecs.id}"
  aws_region                 = "${var.aws_region}"
  account_id                 = "${var.account_id}"
  global_repository          = "${var.global_repository}"
  path                       = "${var.path}"
  example_instance_type      = "${var.example_instance_type}"
  example_max_size           = "${var.example_max_size}"
  example_min_size           = "${var.example_min_size}"
  example_desired_capacity   = "${var.example_desired_capacity}"
  example_container_port     = "${var.example_container_port}"
  example_repository         = "${var.example_repository}"
  example_host_port          = "${var.example_host_port}"
  example_container_protocol = "${var.example_container_protocol}"
  example_memoryReservation  = "${var.example_memoryReservation}"
  example_cpu                = "${var.example_cpu}"
}
