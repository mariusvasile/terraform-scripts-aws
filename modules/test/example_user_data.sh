#!/bin/bash
${ecs_config}
{
  echo 'ECS_CLUSTER=${cluster_name}'
  echo 'ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_logging}'
} >> /etc/ecs/ecs.config