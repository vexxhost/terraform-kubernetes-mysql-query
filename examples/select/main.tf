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

resource "kubernetes_service" "mariadb" {
  metadata {
    generate_name = "mariadb-"
    namespace     = "default"
  }

  spec {
    selector = {
      app = "mariadb"
    }

    port {
      port        = 3306
      target_port = 3306
    }
  }
}

resource "kubernetes_secret" "mariadb" {
  metadata {
    generate_name = "mariadb-"
    namespace     = kubernetes_service.mariadb.metadata[0].namespace
  }

  data = {
    root = "root123"
  }
}

resource "kubernetes_stateful_set" "mariadb" {
  metadata {
    generate_name = "mariadb-"
    namespace     = kubernetes_service.mariadb.metadata[0].namespace
  }

  spec {
    replicas     = 1
    service_name = kubernetes_service.mariadb.metadata[0].name

    selector {
      match_labels = {
        app = "mariadb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mariadb"
        }
      }

      spec {
        container {
          name  = "mariadb"
          image = "mariadb:11"

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name
                key  = "root"
              }
            }
          }

          readiness_probe {
            initial_delay_seconds = 5
            period_seconds        = 5

            tcp_socket {
              port = 3306
            }
          }
        }
      }
    }
  }
}

module "select" {
  source = "../../"

  hostname                  = kubernetes_stateful_set.mariadb.spec[0].service_name
  job_name                  = "mysql-select-test"
  job_namespace             = kubernetes_stateful_set.mariadb.metadata[0].namespace
  root_password_secret_name = kubernetes_secret.mariadb.metadata[0].name

  query = <<-EOT
    SELECT 1;
  EOT
}
