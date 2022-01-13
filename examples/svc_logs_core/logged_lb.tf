// Create a Logged Application Load Balancer -> Forwards Traffic to Dummy Service
// and sinks logs to S3

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "alb" {

  // General
  name               = "tf-svc-logs-alb"
  load_balancer_type = "application"
  internal           = false

  // Network - internet-facing - allow all traffic 
  security_groups = [aws_security_group.lb_sg.id]
  subnets         = [for s in aws_subnet.public : s.id]

  // Logging Configuration
  access_logs {
    bucket  = data.aws_s3_bucket.logs_bucket.id
    enabled = true
  }

  // Misc - Ensure Resources Force Delete!!
  enable_deletion_protection = false
  lifecycle {
    prevent_destroy = false
  }

  // Tags
  tags = {
    Name = "tf-svc-logs-alb"
  }

}

// Create Target Group for Dummy Service
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "grp" {

  // General
  name        = "tf-svc-logs-grp"
  target_type = "instance"
  port        = 8080
  protocol    = "HTTP"

  // Network
  vpc_id = aws_vpc.core.id

  // Health Check Config
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 60
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
    unhealthy_threshold = 2
  }

}

// Explicitly attach individial instances to target group
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "test" {
  for_each = aws_instance.workers

  // General
  target_id        = each.value.id
  port             = aws_lb_target_group.grp.port
  target_group_arn = aws_lb_target_group.grp.arn
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "alb_https_listener_rule" {

  // General
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  // Vanilla Forward Action 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grp.arn
  }

  tags = {
    name = "tf-svc-logs-http-listener"
  }

}