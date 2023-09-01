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

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

resource "random_password" "password" {
  length = 32
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "infra"
  }
}

module "mariadb" {
  source  = "vexxhost/mariadb/kubernetes"
  version = "0.1.1"

  name          = "mariadb"
  namespace     = kubernetes_namespace.namespace.metadata[0].name
  root_password = random_password.password.result
}

module "select" {
  source = "../../"

  depends_on = [
    module.mariadb
  ]

  hostname                  = "mariadb"
  job_name                  = "mysql-select-test"
  job_namespace             = kubernetes_namespace.namespace.metadata[0].name
  root_password_secret_name = "mariadb"

  query = <<-EOT
    SELECT 1;
  EOT
}
