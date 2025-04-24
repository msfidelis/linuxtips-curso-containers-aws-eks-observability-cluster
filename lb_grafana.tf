resource "aws_lb" "grafana" {

  name = format("%s-grafana", var.project_name)

  internal           = false
  load_balancer_type = "application"

  subnets = data.aws_ssm_parameter.lb_grafana_subnets[*].value

  security_groups = [ aws_security_group.grafana.id ]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Name = var.project_name
  }

}

resource "aws_lb_target_group" "grafana" {
  name     = format("%s-grafana", var.project_name)
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc.value

  health_check {
    matcher = "200-299"
    path    = "/healthz"
  }
}


resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_security_group" "grafana" {
  name        = format("%s-grafana", var.project_name)

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

resource "kubectl_manifest" "grafana" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: grafana
  namespace: grafana
spec:
  serviceRef:
    name: grafana
    port: 80
  targetGroupARN: ${aws_lb_target_group.grafana.arn}
  targetType: instance
YAML
  depends_on = [
    helm_release.alb_ingress_controller,
    helm_release.grafana
  ]
}