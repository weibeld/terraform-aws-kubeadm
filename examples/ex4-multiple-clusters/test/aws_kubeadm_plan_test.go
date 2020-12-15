package test

import (
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"path/filepath"
	"testing"
)

// This approach compares the entire plan json output to a static json file in the test directory.
// The file needs to be updated as the configuration changes to pass the test. An improvement would
// be to get targeted plan output for specific resources and use jsonpath to test those resources
// exist in the plan.
func TestKubeAdmClusterConfig(t *testing.T) {
	t.Parallel()

	planFilePath := filepath.Join(".", "plan.out")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "..",
		PlanFilePath: planFilePath,

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"test_terraform.tfvars"},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
		// Disable logging
		Logger: logger.New(logger.Discard),
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and `terraform show` and return the plan
	// json at `PlanFilePath` and fail the test if there are any errors.
	planJson := terraform.InitAndPlanAndShow(t, terraformOptions)

	// Use jsonpath to extract the expected json nodes on the instance from the plan. You can alternatively
	// use https://github.com/hashicorp/terraform-json to get a concrete struct with all the types resolved.
	var actualConfig []map[string]interface{}
	var expectedConfig []map[string]interface{}

	k8s.UnmarshalJSONPath(
		t,
		[]byte(planJson),
		"{  }",
		&actualConfig,
	)

	expectedBuf, _ := ioutil.ReadFile(filepath.Join(".", "plan_config.json"))

	k8s.UnmarshalJSONPath(
		t,
		expectedBuf,
		"{  }",
		&expectedConfig,
	)

	assert.Equal(t, expectedConfig, actualConfig)

}
