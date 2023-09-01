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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

resource "kubernetes_job" "query" {
  #ts:skip=AC_K8S_0064 https://github.com/tenable/terrascan/issues/1610
  metadata {
    name      = var.job_name
    namespace = var.job_namespace
  }

  spec {
    backoff_limit = 0

    template {
      metadata {}
      spec {
        restart_policy = "Never"

        security_context {
          run_as_non_root = true
          run_as_user     = "999"
          run_as_group    = "999"
        }

        container {
          name    = "query"
          image   = var.image
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
              mariadb -h$DATABASE_HOSTNAME -uroot -p$DATABASE_ROOT_PASSWORD -e "${var.query}"
            EOT
          ]

          env {
            name  = "DATABASE_HOSTNAME"
            value = var.hostname
          }
          env {
            name = "DATABASE_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.root_password_secret_name
                key  = var.root_password_secret_key
              }
            }
          }

          dynamic "env" {
            for_each = var.env

            content {
              name  = env.key
              value = env.value
            }
          }

          security_context {
            read_only_root_filesystem  = true
            privileged                 = false
            allow_privilege_escalation = false

            run_as_non_root = true
            run_as_user     = "999"
            run_as_group    = "999"

            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }

  wait_for_completion = true
  timeouts {
    create = "1m"
    update = "1m"
  }
}
