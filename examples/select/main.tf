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

// TODO: We should build a Terraform module which handles/manages the creation
//       of database, but for now we just deploy a simple container.
resource "helm_release" "pxc_operator" {
  name      = "pxc-operator"
  namespace = "default"

  repository = "https://percona.github.io/percona-helm-charts"
  chart      = "pxc-operator"
  version    = "1.13.1"
}
resource "kubernetes_manifest" "pxc_cluster" {
  depends_on = [
    helm_release.pxc_operator
  ]

  manifest = {
    apiVersion = "pxc.percona.com/v1"
    kind       = "PerconaXtraDBCluster"
    metadata = {
      name      = "database"
      namespace = helm_release.pxc_operator.metadata[0].namespace
    }
    spec = {
      allowUnsafeConfigurations = true
      crVersion                 = "1.13.0"
      haproxy = {
        enabled = true
        size    = 1
        image   = "percona/percona-xtradb-cluster-operator:1.13.0-haproxy"
      }
      pxc = {
        size  = 1
        image = "percona/percona-xtradb-cluster:5.7.39-31.61"
        volumeSpec = {
          persistentVolumeClaim = {
            resources = {
              requests = {
                storage = "5G"
              }
            }
          }
        }
      }
    }
  }

  wait {
    condition {
      type   = "ready"
      status = "True"
    }
  }
}

module "select" {
  source = "../../"

  hostname                  = "${kubernetes_manifest.pxc_cluster.manifest.metadata.name}-haproxy.${kubernetes_manifest.pxc_cluster.manifest.metadata.namespace}"
  job_name                  = "mysql-select-test"
  job_namespace             = kubernetes_manifest.pxc_cluster.manifest.metadata.namespace
  root_password_secret_name = "${kubernetes_manifest.pxc_cluster.manifest.metadata.name}-secrets"

  query = <<-EOT
    SELECT 1;
  EOT
}
