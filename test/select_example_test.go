// Copyright (c) 2023 VEXXHOST, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

type KindCluster struct {
	Name string
	*testing.T
}

func NewKindCluster(t *testing.T) *KindCluster {
	return &KindCluster{
		Name: strings.ToLower(random.UniqueId()),
		T:    t,
	}
}

func (k *KindCluster) Create() {
	shell.RunCommand(k.T, shell.Command{
		Command: "kind",
		Args:    []string{"create", "cluster", "--name", k.Name},
	})
}

func (k *KindCluster) Delete() {
	shell.RunCommand(k.T, shell.Command{
		Command: "kind",
		Args:    []string{"delete", "cluster", "--name", k.Name},
	})
}

func (k *KindCluster) EnvVars() map[string]string {
	return map[string]string{
		"KUBE_CONFIG_PATH": fmt.Sprintf("%s/.kube/config", os.Getenv("HOME")),
		"KUBE_CTX":         fmt.Sprintf("kind-%s", k.Name),
	}
}

func TestSelectExample(t *testing.T) {
	cluster := NewKindCluster(t)

	cluster.Create()
	defer cluster.Delete()

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/select",
		EnvVars:      cluster.EnvVars(),
	})
	defer terraform.Destroy(t, options)

	terraform.InitAndApply(t, options)
}
