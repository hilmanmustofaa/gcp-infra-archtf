/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region to deploy resources."
  type        = string
  default     = "asia-southeast2"
}

variable "kms_key_name" {
  description = "The Customer-Managed Encryption Key for disk encryption."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the SSL certificate."
  type        = string
  default     = "demo.example.com"
}

variable "whitelist_ips" {
  description = "List of IP ranges to whitelist in Cloud Armor."
  type        = list(string)
  default     = ["203.0.113.0/24"]
}

variable "default_labels" {
  description = "Mandatory FinOps labels."
  type        = map(string)
  default = {
    env     = "prod"
    project = "web-infra"
    owner   = "sre-team"
  }
}
