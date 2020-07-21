[
      {
         "name":"${example_container_name}",
         "image": "${example_image}",
         "memoryReservation": ${example_memoryReservation},
         "cpu": ${example_cpu},
         "portMappings":[
            {
               "containerPort": ${example_container_port},
               "hostPort": ${example_host_port},
               "protocol":"${example_protocol}"
            }
         ],
         "privileged":true,
         "essential":true,
         "readonlyRootFilesystem":false
      }
]