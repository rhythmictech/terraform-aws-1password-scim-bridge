# terraform-aws-1password-scim-bridge

Creates a SCIM Bridge to enable 1Password SSO w/Okta and other SSO providers. Based on the [1Password SCIM Examples](https://github.com/1Password/scim-examples), but packaged as a ready-to-use module with some security-related improvements.

[![tflint](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-1password-scim-bridge/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.19 |
| aws | >= 2.65 |
| template | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.65 |
| template | >= 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_log\_bucket | Bucket name to route ELB access logs to | `string` | n/a | yes |
| access\_log\_prefix | Bucket prefix to route ELB access logs to | `string` | n/a | yes |
| certificate\_arn | ARN of ACM Certificate to use for ELB | `string` | n/a | yes |
| private\_subnets | Private subnets to associate SCIM instances with (specify 1 or more) | `list(string)` | n/a | yes |
| public\_subnets | Public subnets to associate ELB with (specify at least 2) | `list(string)` | n/a | yes |
| route53\_zone\_id | Zone ID to register Route53 entry in | `string` | n/a | yes |
| scim\_host\_name | Fully qualified host name (e.g., prod-1password-scim.mycompany.io) | `string` | n/a | yes |
| scim\_secret\_name | Friendly name of manually created secret | `string` | n/a | yes |
| vpc\_id | VPC ID | `string` | n/a | yes |
| ami\_id | AMI to build on (must be Ubuntu, `ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*` used if this is null) | `string` | `null` | no |
| asg\_additional\_iam\_policies | Additional IAM policies to attach to the  ASG instance profile | `list(string)` | `[]` | no |
| asg\_additional\_security\_groups | Additional security group IDs to attach to ASG instances | `list(string)` | `[]` | no |
| asg\_additional\_user\_data | Additional User Data to attach to the launch template | `string` | `""` | no |
| asg\_allow\_outbound\_egress | whether or not the default SG should allow outbound egress | `bool` | `true` | no |
| asg\_desired\_capacity | The number of Amazon EC2 instances that should be running in the group. | `number` | `1` | no |
| asg\_instance\_type | Instance type for scim app | `string` | `"t3a.micro"` | no |
| asg\_keypair | Optional keypair to associate with instances | `string` | `null` | no |
| asg\_max\_size | Maximum number of instances in the autoscaling group | `number` | `2` | no |
| asg\_min\_size | Minimum number of instances in the autoscaling group | `number` | `1` | no |
| elb\_allowed\_cidrs | List of CIDRs that can reach the ELB (must be reachable by the SSO provider) | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| name | Name of this deployment (e.g., prod-1password-scim) | `string` | `"1password-scim"` | no |
| scim\_cache\_dns\_name | Redis cache DNS name (this changes the port SCIM tries to reach redis on but does not change the address redis listens on) | `string` | `"localhost"` | no |
| scim\_cache\_port | Redis cache port (this changes the port SCIM tries to reach redis on but does not change the port redis listens on) | `string` | `"6379"` | no |
| scim\_group | unprivileged group to run op-scim service | `string` | `"nogroup"` | no |
| scim\_path | op-scim working directory path (e.g: /var/lib/op-scim) | `string` | `"/var/lib/op-scim"` | no |
| scim\_port | Port SCIM should listen on | `number` | `3002` | no |
| scim\_repo | Repo/package to pull `op-scim` from | `string` | `"deb https://apt.agilebits.com/op-scim/ stable op-scim"` | no |
| scim\_session\_path | op-scim scimsession file path (e.g: /var/lib/op-scim/.op/scimsession) | `string` | `"/var/lib/op-scim/.op/scimsession"` | no |
| scim\_user | unprivileged user to run op-scim service | `string` | `"op-scim"` | no |
| tags | Tags to add to supported resources | `map(string)` | `{}` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# See Also
* [1Password SCIM Bridge](https://support.1password.com/scim/)
