resource "aws_cloudwatch_event_rule" "kill_rule" {
  name_prefix = "KillEvent-"
  description = "Scheduled event to kill resources."
  is_enabled  = var.kill_rule_enabled

  schedule_expression = var.kill_resources_schedule

}

resource "aws_cloudwatch_event_rule" "revive_rule" {
  name_prefix = "ReviveEvent-"
  description = "Scheduled event to revive resources."
  is_enabled  = var.revive_rule_enabled

  schedule_expression = var.revive_resources_schedule

}

resource "aws_cloudwatch_event_target" "kill_resources" {
  arn      = aws_codebuild_project.switch_codebuild_project.arn
  input    = <<DOC
{
  "environmentVariablesOverride": [
    {
      "name": "TF_INIT_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_init_parameter.name}"
    },
    {
      "name": "TF_APPLY_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_kill_parameter.name}"
    },
    {
      "name": "TERRAFORM_VERSION_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_version_parameter.name}"
    }
  ]
}
DOC
  rule     = aws_cloudwatch_event_rule.kill_rule.name
  role_arn = aws_iam_role.codebuild_role.arn

}

resource "aws_cloudwatch_event_target" "revive_resources" {
  arn      = aws_codebuild_project.switch_codebuild_project.arn
  input    = <<DOC
{
  "environmentVariablesOverride": [
    {
      "name": "TF_INIT_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_init_parameter.name}"
    },
    {
      "name": "TF_APPLY_COMMAND_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_revive_parameter.name}"
    },
    {
      "name": "TERRAFORM_VERSION_SSM_NAME",
      "type": "PLAINTEXT",
      "value": "${aws_ssm_parameter.tf_version_parameter.name}"
    }
  ]
}
DOC
  rule     = aws_cloudwatch_event_rule.revive_rule.name
  role_arn = aws_iam_role.codebuild_role.arn

}

data "aws_iam_policy_document" "codebuild_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.switch_codebuild_project.arn]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix        = "StartSwitchRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust.json
}

resource "aws_iam_policy" "codebuild_policy" {
  name_prefix = "StartSwitchPolicy"
  policy      = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild_attachment" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild_role.name
}