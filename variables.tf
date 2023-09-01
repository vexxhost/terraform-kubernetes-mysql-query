# Copyright (c) 2023 VEXXHOST, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

variable "job_namespace" {
  type        = string
  description = "Namespace for the job running the query"
}

variable "job_name" {
  type        = string
  description = "Name of the job running the query"
}

variable "hostname" {
  type        = string
  description = "Hostname of the database"
}

variable "root_password_secret_name" {
  type        = string
  description = "Name of the secret containing the root password"
}

variable "root_password_secret_key" {
  type        = string
  default     = "root"
  description = "Key of the secret containing the root password"
}

variable "image" {
  type        = string
  default     = "docker.io/library/mariadb:11"
  description = "Image to use for the database client"
}

variable "query" {
  type        = string
  description = "Query to run"
}

variable "env" {
  type        = map(string)
  default     = {}
  description = "Additional environment variables to pass to the container"
}
