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


module "tfstate" {
  source  = "../../modules/lb-access"
  context = module.context.self

  access_log_bucket_name            = ""
  access_log_bucket_prefix_override = ""
  create_kms_key                    = true
  enable_mfa_delete                 = false
  enable_versioning                 = true
  force_destroy                     = true
  kms_key_deletion_window_in_days   = 30
  kms_key_enable_key_rotation       = true
  lifecycle_configuration_rules     = []
  s3_object_ownership               = "BucketOwnerPreferred"
  s3_replication_enabled            = false
  s3_replication_rules              = var.s3_lifecycle_configuration_rules
  s3_replication_source_roles       = []
  s3_source_policy_documents        = []
}
