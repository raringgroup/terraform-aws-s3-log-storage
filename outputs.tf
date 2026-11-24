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

output "bucket_domain_name" {
  value       = module.aws_s3_bucket.bucket_domain_name
  description = "FQDN of bucket"
}

output "bucket_regional_domain_name" {
  value       = module.aws_s3_bucket.bucket_regional_domain_name
  description = "Regional FQDN of bucket."
}

output "bucket_id" {
  value       = try(module.aws_s3_bucket.bucket_id, null)
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = module.aws_s3_bucket.bucket_arn
  description = "Bucket ARN"
}

output "bucket_notifications_sqs_queue_arn" {
  value       = join("", aws_sqs_queue.notifications.*.arn)
  description = "Notifications SQS queue ARN"
}

output "enabled" {
  value       = module.context.enabled
  description = "Is module enabled"
}
