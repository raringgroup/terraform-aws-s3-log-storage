## ----------------------------------------------------------------------------
## Copyright 2026 Raring Group LLC
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# KMS Key Policy Context
# ------------------------------------------------------------------------------
module "kms_key_context" {
  source  = "git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0"
  context = module.s3_log_storage_context.self
  enabled = var.create_kms_key && module.context.enabled
}


# ------------------------------------------------------------------------------
# KMS Key Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "kms_key" {
  #checkov:skip=CKV_AWS_356:skipping 'Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions'
  count = module.kms_key_context.enabled ? 1 : 0

  statement {
    sid    = "AwsRootAccess"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:Tag*",
      "kms:Untag*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    #bridgecrew:skip=CKV_AWS_109:This policy applies only to the key it is attached to
    #bridgecrew:skip=CKV_AWS_111:This policy applies only to the key it is attached to
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["${local.arn_prefix}:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid    = "AwsSourceAccountAccess"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
    ]
    #bridgecrew:skip=CKV_AWS_109:This policy applies only to the key it is attached to
    #bridgecrew:skip=CKV_AWS_111:This policy applies only to the key it is attached to
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [for account in var.source_accounts : "${local.arn_prefix}:iam::${account}:root"]
    }
  }

  statement {
    sid    = "AwsCloudfrontAccess"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = concat([local.account_id], var.source_accounts)
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = concat(
        ["${local.arn_prefix}:logs:*:${local.account_id}:*"],
        [for account in var.source_accounts : "arn:aws:logs:*:${account}:*"]
      )
    }
  }
}


# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
module "kms_key" {
  source  = "git::https://github.com/raringgroup/terraform-aws-kms-key.git?ref=v0.1.0"
  context = module.kms_key_context.self

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_key_deletion_window_in_days
  description              = "KMS key for AWS Config Logs"
  enable_key_rotation      = var.kms_key_enable_key_rotation
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = join("", data.aws_iam_policy_document.kms_key.*.json)
}
