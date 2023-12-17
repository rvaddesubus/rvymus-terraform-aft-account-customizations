data "aws_caller_identity" "current" {}

variable britive_idp_name {
  description = "The name of the SAML Identity Provider role trustee."
  type = string
  default = "Britive-ymus"
}

variable britive_admin_role_name {
  description = "Name of Integration RoleName"
  type = string
  default = "stationdm-admin-prod-role-test"
}

variable britive_app_role_name {
  description = "Name of Integration RoleName"
  type = string
  default = "stationdm-app-prod-role"
}

variable britive_read_only_role_name {
  description = "Name of Integration RoleName"
  type = string
  default = "stationdm-readonly-prod-role"
}

 data "aws_iam_policy_document" "assume_role" {
    statement {
      actions = ["sts:AssumeRole"]
      principals {
        type "Federated"
        identifiers  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/${var.britive_idp_name}"]
      }
      condition = {
        stringEquals = {
          "SAML:aud" = "https://signin.aws.amazon.com/saml"
        }
      }
    }
  }
  
resource "aws_iam_role" "britive_admin_role" {
  name = var.britive_admin_role_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  path = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

resource "aws_iam_role" "britive_app_role" {
  name = var.britive_app_role_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  path = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}

resource "aws_iam_role" "britive_read_only_role" {
  name = var.britive_read_only_role_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  path = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}