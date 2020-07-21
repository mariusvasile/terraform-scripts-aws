##############################
# ECS cluster
##############################

resource "aws_ecs_cluster" "example" {
  name = "${var.team}-example-${var.environment}"
}

resource "aws_launch_configuration" "example" {
  name                 = "${var.team}-example-launch-config-${var.environment}"
  image_id             = "${var.ami_id}"
  instance_type        = "${var.example_instance_type}"
  user_data            = "${data.template_file.example_user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.example.id}"


  lifecycle {
    create_before_destroy = false
  }
}

data "template_file" "example_user_data" {
  template = "${file("${path.module}/example_user_data.sh")}"

  vars = {
    ecs_config      = "${var.ecs_config}"
    ecs_logging     = "${var.ecs_logging}"
    cluster_name    = "${var.team}-example-${var.environment}"
    env_name        = "${var.environment}"
    custom_userdata = "${var.custom_userdata}"
  }
}

resource "aws_autoscaling_group" "pricing-api" {
  name                 = "${var.team}-example-asg-${var.environment}"
  max_size             = "${var.example_max_size}"
  min_size             = "${var.example_min_size}"
  desired_capacity     = "${var.example_desired_capacity}"
  launch_configuration = "${aws_launch_configuration.example.name}"
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "${var.team}-example-${var.environment}"
    propagate_at_launch = "true"
  }
}

resource "aws_iam_role" "example_ecs_instance_role" {
  name = "${var.team}-example-ecs-instance-role-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example_ecs_instance_policy" {
  name   = "${var.team}-example-ecs-instance-policy-${var.environment}"
  role   = "${aws_iam_role.example_ecs_instance_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*"
        ]
    }
  ]

}
EOF
}

resource "aws_iam_instance_profile" "example" {
  name = "${var.team}-example-ecs-instance-profile-${var.environment}"
  path = "${var.path}"
  role = "${aws_iam_role.example_ecs_instance_role.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.example_ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


#######################################
# Example task definintion
#######################################
resource "aws_ecs_task_definition" "example-td" {
  container_definitions = "${data.template_file.example.rendered}"
  family                = "${var.team}-example-td-${var.environment}"
  execution_role_arn    = "${aws_iam_role.example_ecs_task_execution_role.arn}"
}

resource "aws_iam_role" "example_task_definition_role" {
  name = "${var.team}-example-task-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "example_ecs_task_execution_role" {
  name = "${var.team}-example-task-execution-role-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "example_ecs_task_execution_role" {
  name   = "${var.team}-example-ecs-task-execution-${var.environment}"
  policy = "${data.template_file.example_task_execution_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "example_ecs_task_execution_role" {
  role       = "${aws_iam_role.example_ecs_task_execution_role.name}"
  policy_arn = "${aws_iam_policy.example_ecs_task_execution_role.arn}"
}

resource "aws_iam_policy" "example_env_var_ecs_task_execution_role" {
  name   = "${var.team}-example-env-var-${var.environment}"
  policy = "${data.template_file.example_task_execution_env_var_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = "${aws_iam_role.example_ecs_task_execution_role.name}"
  policy_arn = "${aws_iam_policy.example_env_var_ecs_task_execution_role.arn}"
}

resource "aws_iam_policy" "example_ecs_task_definition" {
  name   = "${var.team}-example-ecs-default-task-${var.environment}"
  policy = "${data.template_file.example_task_definition_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "example_ecs_default_task" {
  role       = "${aws_iam_role.example_task_definition_role.name}"
  policy_arn = "${aws_iam_policy.example_ecs_task_definition.arn}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  role       = "${aws_iam_role.example_ecs_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy" "example_ecs_task_policy" {
  name   = "${var.team}-example-ecs-instance-policy-${var.environment}"
  role   = "${aws_iam_role.example_ecs_task_execution_role.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*"
        ]
    }
  ]

}
EOF
}

#############################
# Example ECR repository
############################

resource "aws_ecr_repository" "example" {
  name = "${var.team}-example-${var.environment}"
}

resource "aws_ecr_repository_policy" "example_ecrpolicy" {
  repository = "${aws_ecr_repository.example.name}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "ecr:BatchCheckLayerAvailability",
              "ecr:BatchGetImage",
              "ecr:CompleteLayerUpload",
              "ecr:GetDownloadUrlForLayer",
              "ecr:InitiateLayerUpload",
              "ecr:ListImages",
              "ecr:PutImage",
              "ecr:UploadLayerPart"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecr_access" {
  name   = "${var.team}-example-ecr-access-policy-${var.environment}"
  role   = "${aws_iam_role.example_ecs_task_execution_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_ecr_repository.example.arn}",
        "${aws_ecr_repository.example.arn}"}/*"
      ]
    }
  ]

}
EOF
}
