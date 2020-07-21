data "template_file" "example" {
  template = "${file("${path.module}/example-container.tpl")}"

  vars = {
    example_container_port    = "${var.example_container_port}"
    example_container_name    = "${var.team}-example-${var.environment}"
    example_image             = "${var.global_repository}/${var.example_repository}:latest"
    example_host_port         = "${var.example_host_port}"
    example_protocol          = "${var.example_container_protocol}"
    aws_region                = "${var.aws_region}"
    account_id                = "${var.account_id}"
    example_memoryReservation = "${var.example_memoryReservation}"
    example_cpu               = "${var.example_cpu}"
  }
}

data "template_file" "example_task_definition_policy" {
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RegisterContainerInstance",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Submit*",
        "ecs:Poll",
        "ecs:StartTask",
        "ecs:StartTelemetrySession"
        ],
      "Resource": [
        "*"
        ]
     }
   ]
}
EOF

}

data "template_file" "example_task_execution_policy" {
  template = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-2:${var.account_id}:parameter/SECRET_ACCESS_KEY",
        "arn:aws:ssm:eu-west-2:${var.account_id}:parameter/ACCESS_KEY",
        "arn:aws:kms:eu-west-2:${var.account_id}:key/alias/aws/ssm"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

}


data "template_file" "example_task_execution_env_var_policy" {
  template = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:eu-west-2:${var.account_id}:secret:example-test-td-user-credentials"
            ]
        }
    ]
}
EOF

}
