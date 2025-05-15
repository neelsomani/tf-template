# for env variable secrets
data "aws_iam_policy_document" "secrets_policy" {
  statement {
    sid = "SecretsManagerGet"
    actions = [
      "secretsmanager:Get*",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "secrets_policy" {
  name        = "${var.environment}-secrets-policy"
  description = "Permissions to access secrets"
  policy      = data.aws_iam_policy_document.secrets_policy.json
}

# for execing into a container
data "aws_iam_policy_document" "exec_policy" {
  statement {
    sid = "SSMMessages"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "exec_policy" {
  name        = "${var.environment}-exec-policy"
  description = "Permissions to exec into a container"
  policy      = data.aws_iam_policy_document.exec_policy.json
}
