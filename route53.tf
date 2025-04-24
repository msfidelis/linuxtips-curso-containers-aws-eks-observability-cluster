resource "aws_route53_zone" "private" {
  name = format("%s.local", var.project_name)

  vpc {
    vpc_id = data.aws_ssm_parameter.vpc.value
  }
}


resource "aws_route53_record" "loki" {
  zone_id = aws_route53_zone.private.zone_id
  name    = format("loki.%s.local",  var.project_name)
  type    = "CNAME"
  ttl     = "30"
  records = [aws_lb.loki.dns_name]
}