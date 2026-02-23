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

variable "organization_id" {
  description = "The organization ID (organizations/nnnnnn)."
  type        = string
}

variable "billing_account" {
  description = "The billing account ID to associate with the project."
  type        = string
}

variable "region" {
  description = "The default region."
  type        = string
  default     = "asia-southeast2"
}

variable "default_labels" {
  description = "Default labels for FinOps compliance."
  type        = map(string)
  default = {
    env     = "prod"
    project = "governance"
    owner   = "toylabs"
  }
}
