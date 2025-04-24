resource "aws_lb" "tempo" {

  name = format("%s-tempo", var.project_name)

  internal           = true
  load_balancer_type = "network"

  subnets = data.aws_ssm_parameter.lb_subnets[*].value

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Name = var.project_name
  }

}

resource "aws_lb_target_group" "tempo" {
  name     = format("%s-tempo", var.project_name)
  port     = 80
  protocol = "TCP"
  vpc_id   = data.aws_ssm_parameter.vpc.value
}

resource "aws_lb_listener" "tempo" {
  load_balancer_arn = aws_lb.tempo.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tempo.arn
  }
}

resource "kubectl_manifest" "tempo" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: tempo-gateway
  namespace: tempo
spec:
  serviceRef:
    name: tempo-gateway
    port: 80
  targetGroupARN: ${aws_lb_target_group.tempo.arn}
  targetType: instance
YAML
  depends_on = [
    helm_release.alb_ingress_controller,
    helm_release.tempo
  ]
}