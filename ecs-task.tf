resource "aws_ecs_task_definition" "task_container_file" {
  count                    = 0
  family                   = "tasks"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  container_definitions = file(
    "${path.module}/resources/ecs-task-definitions/nginx.json"
  )
}

resource "aws_ecs_service" "service_file" {
  count           = 0
  name            = "my_service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.task_container_file[0].id
  # Creating services with 2 instances to start
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.sg.id]
    subnets          = [aws_subnet.subnet.id]
  }
}