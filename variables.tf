variable "environment" {
}

variable "team" {

}

variable "example_instance_type" {

}

variable "example_max_size" {

}

variable "example_min_size" {

}

variable "example_desired_capacity" {

}

variable "path" {

}

variable "custom_userdata" {
  default     = ""
  description = "Inject extra command in the instance template to be run on boot"
}

variable "ecs_config" {
  default     = "echo '' > /etc/ecs/ecs.config"
  description = "Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config"
}

variable "ecs_logging" {
  default     = "[\"json-file\",\"awslogs\"]"
  description = "Adding logging option to ECS that the Docker containers can use. It is possible to add fluentd as well"
}

variable "instance_group" {
  default     = "default"
  description = "The name of the instances that you consider as a group"
}

variable "example_container_port" {

}

variable "example_host_port" {

}

variable "example_container_protocol" {

}

variable "aws_region" {

}

variable "global_repository" {

}

variable "example_repository" {

}

variable "account_id" {

}

variable "example_memoryReservation" {

}

variable "example_cpu" {

}

