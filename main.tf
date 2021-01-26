data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-scim-sg"
  description = "SCIM instance SG"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    map(
      "Name", "${var.name}-scim-sg"
    )
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this_allow_egress" {
  count             = var.asg_allow_outbound_egress ? 1 : 0
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  description       = "Allow outbound egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "this_allow_elb" {
  description              = "Allow ELB to reach SCIM port"
  from_port                = var.scim_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.this.id
  source_security_group_id = aws_security_group.elb.id
  to_port                  = var.scim_port
  type                     = "ingress"
}

data "aws_ami" "this" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "this" {
  template = file("${path.module}/userdata.yml.tpl")

  vars = {
    FQDN                = var.scim_host_name
    REDIS               = var.scim_cache_dns_name
    REDISPORT           = var.scim_cache_port
    REGION              = local.region
    SCIM_USER           = var.scim_user
    SCIM_GROUP          = var.scim_group
    SCIM_PATH           = var.scim_path
    SCIM_SESSION_PATH   = var.scim_session_path
    SCIM_SESSION_SECRET = var.scim_secret_name
    SCIM_REPO           = var.scim_repo
  }
}

data "template_cloudinit_config" "this" {

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.this.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = var.asg_additional_user_data
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix               = var.name
  desired_capacity          = var.asg_desired_capacity
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = false
  launch_configuration      = aws_launch_configuration.this.name
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  target_group_arns         = [aws_lb_target_group.this.arn]
  wait_for_capacity_timeout = "15m"
  vpc_zone_identifier       = var.private_subnets

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = var.name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.this.id
  image_id                    = coalesce(var.ami_id, data.aws_ami.this.id)
  instance_type               = var.asg_instance_type
  key_name                    = var.asg_keypair
  user_data_base64            = data.template_cloudinit_config.this.rendered

  security_groups = concat(
    var.asg_additional_security_groups,
    [aws_security_group.this.id]
  )

  root_block_device {
    encrypted   = true
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "this" {
  name    = var.scim_host_name
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
