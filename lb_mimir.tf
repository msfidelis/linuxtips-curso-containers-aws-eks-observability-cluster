resource "aws_lb" "mimir" {

  name = format("%s-mimir", var.project_name)

  internal           = true
  load_balancer_type = "application"

  subnets = data.aws_ssm_parameter.lb_subnets[*].value

  security_groups = [
    aws_security_group.mimir.id
  ]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Name = var.project_name
  }

}

resource "aws_lb_target_group" "mimir" {
  name     = format("%s-mimir", var.project_name)
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc.value
}

resource "aws_lb_listener" "mimir" {
  load_balancer_arn = aws_lb.mimir.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mimir.arn
  }
}

resource "aws_security_group" "mimir" {
  name        = format("%s-mimir", var.project_name)

  vpc_id      = data.aws_ssm_parameter.vpc.value

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.project_name    
  }
}

resource "kubectl_manifest" "mimir" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: mimir-nginx
  namespace: mimir
spec:
  serviceRef:
    name: mimir-nginx
    port: 80
  targetGroupARN: ${aws_lb_target_group.mimir.arn}
  targetType: instance
YAML
  depends_on = [
    helm_release.alb_ingress_controller,
    helm_release.mimir
  ]
}