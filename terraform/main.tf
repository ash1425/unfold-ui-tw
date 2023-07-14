resource "aws_ecs_cluster" "unfold-ui-ecs-cluster" {
  name = "unfold-ui-ecs-cluster"
}


# creating an iam policy document for ecsTaskExecutionRole
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# creating an iam role with needed permissions to execute tasks
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# attaching AmazonECSTaskExecutionRolePolicy to ecsTaskExecutionRole
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "readParams_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_cloudwatch_log_group" "lg" {
  name              = "/team/unfold-ui-nextjs-app"
  retention_in_days = 1
}

# Creating the task definition
resource "aws_ecs_task_definition" "unfold-ui-nextjs-app-task" {
  family                   = "unfold-ui-nextjs-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([
    {
      name             = "unfold-ui-nextjs-app-container"
      image            = "public.ecr.aws/j5l0m1q0/unfold-ui-next-app:latest"
      essential        = true
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.lg.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      memory = 512
      cpu    = 256
    }
  ])
}


# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}

# Creating a load balancer
resource "aws_alb" "unfold-ui-nextjs-app-lb" {
  name               = "unfold-ui-nextjs-app-lb" # Naming our load balancer
  load_balancer_type = "application"
  subnets            = [
    # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.unfold-ui-nextjs-app-lb_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "unfold-ui-nextjs-app-lb_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a target group for the load balancer
resource "aws_lb_target_group" "unfold-ui-nextjs-app-target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC
  health_check {
    matcher = "200,301,302,307,308"
    path    = "/en"
  }
}

# Creating a listener for the load balancer
resource "aws_lb_listener" "unfold-ui-nextjs-app-listener" {
  load_balancer_arn = aws_alb.unfold-ui-nextjs-app-lb.arn # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.unfold-ui-nextjs-app-target_group.arn # Referencing our target group
  }
}

# Creating the service
resource "aws_ecs_service" "unfold-ui-nextjs-app-service" {
  name            = "unfold-ui-nextjs-app-service"
  cluster         = aws_ecs_cluster.unfold-ui-ecs-cluster.id       # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.unfold-ui-nextjs-app-task.arn
  # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Setting the number of containers we want deployed to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.unfold-ui-nextjs-app-target_group.arn # Referencing our target group
    container_name   = "unfold-ui-nextjs-app-container"
    container_port   = 3000 # Specifying the container port
  }

  network_configuration {
    subnets = [
      "${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}",
      "${aws_default_subnet.default_subnet_c.id}"
    ]
    assign_public_ip = true                                                # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.unfold-ui-nextjs-app-service_security_group.id}"]
    # Setting the security group
  }
}

# Creating a security group for the service
resource "aws_security_group" "unfold-ui-nextjs-app-service_security_group" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.unfold-ui-nextjs-app-lb_security_group.id}"]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_alb.unfold-ui-nextjs-app-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.unfold-ui-nextjs-app-target_group.arn
  }
}

resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_alb.unfold-ui-nextjs-app-lb.dns_name
    origin_id   = "my-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-alb-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "lb_dns" {
  value       = aws_alb.unfold-ui-nextjs-app-lb.dns_name
  description = "AWS load balancer DNS Name"
}

output "cloudfront" {
  value       = aws_cloudfront_distribution.my_distribution.domain_name
  description = "AWS Cloudfront DNS Name"
}