data "aws_iam_policy_document" "this" {
  # TODO figure out why describetags is needed and if it can be
  # constrained to the ASG
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = ["arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.scim_secret_name}-*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-policy"
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.this.id
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "additional" {
  count      = length(var.asg_additional_iam_policies)
  role       = aws_iam_role.this.name
  policy_arn = var.asg_additional_iam_policies[count.index]
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = aws_iam_role.this.name
}
