resource "aws_lb" "loki" {

  name = format("%s-loki", var.project_name)

  internal           = true
  load_balancer_type = "network"

  subnets = data.aws_ssm_parameter.lb_subnets[*].value

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Name = var.project_name
  }

}

resource "aws_lb_target_group" "loki" {
  name     = format("%s-http", var.project_name)
  port     = 80
  protocol = "TCP"
  vpc_id   = data.aws_ssm_parameter.vpc.value
}

resource "aws_lb_listener" "loki" {
  load_balancer_arn = aws_lb.loki.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loki.arn
  }
}

resource "kubectl_manifest" "loki" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: loki-gateway
  namespace: loki
spec:
  serviceRef:
    name: loki-gateway
    port: 80
  targetGroupARN: ${aws_lb_target_group.loki.arn}
  targetType: instance
YAML
  depends_on = [
    helm_release.alb_ingress_controller,
    helm_release.loki
  ]
}