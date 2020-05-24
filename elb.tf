resource "aws_security_group" "elb" {
  name_prefix = "${var.name}-elb-sg"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    map(
      "Name", "${var.name}-elb-sg"
    )
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "elb_allow_ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.elb.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "elb_allow_egress" {
  from_port                 = var.scim_port
  protocol                  = "tcp"
  security_group_id         = aws_security_group.elb.id
  source_security_group_id = aws_security_group.this.id
  to_port                   = var.scim_port
  type                      = "egress"
}

resource "aws_lb" "this" {
  name_prefix                      = substr(var.name, 0, 6)
  enable_cross_zone_load_balancing = true
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.elb.id]
  subnets                          = var.public_subnets
  tags                             = var.tags
}

resource "aws_lb_listener" "this" {
  certificate_arn   = var.certificate_arn
  load_balancer_arn = aws_lb.this.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = aws_lb_target_group.this.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "this" {
  name_prefix = substr(var.name, 0, 6)
  port        = var.scim_port
  protocol    = "HTTP"
  tags        = var.tags
  vpc_id      = var.vpc_id

  health_check {
    interval            = 10
    path                = "/ping"
    port                = var.scim_port
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}
