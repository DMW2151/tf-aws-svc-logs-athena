package test

// Terraform Tests w. https://github.com/gruntwork-io/terratest
import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/athena"
	"github.com/aws/aws-sdk-go/service/glue"
	"github.com/gruntwork-io/terratest/modules/terraform"
	log "github.com/sirupsen/logrus"
	"github.com/stretchr/testify/assert"
	"os"
	"testing"
)

// Create a Glue client with additional configuration
var (
	sess = session.Must(session.NewSession())

	G = glue.New(
		sess, aws.NewConfig().WithRegion("us-east-1"),
	)

	A = athena.New(
		sess, aws.NewConfig().WithRegion("us-east-1"),
	)
)

var (
	dbName  = "svc_logs"
	tblName = "alb_001"
)

func init() {
	// Log as JSON instead of the default ASCII formatter.
	log.SetFormatter(&log.JSONFormatter{})

	// Output to stdout instead of the default stderr
	// Can be any io.Writer, see below for File example
	log.SetOutput(os.Stdout)

	// Only log the warning severity or above.
	log.SetLevel(log.InfoLevel)
}

func TestTerraformALB(t *testing.T) {

	// Retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/alb",
	})

	defer terraform.Destroy(t, terraformOptions)

	// Create Resources
	//
	// NOTE: The `alb` examples do not rely on terratest's aws module to create a
	// bucket or put a bucket policy, s3 resources are configured in the example itself

	terraform.InitAndApply(t, terraformOptions)

	// Check table exists w. AWS SDK && retrieves the table definition from default
	// Data Catalog

	// Check via Glue and Athena Methods to get *slightly* different data
	if _, err := G.GetTable(&glue.GetTableInput{
		DatabaseName: &dbName,
		Name:         &tblName,
	}); err != nil {
		// Fail Tests - Table Not Found...

	} else {
		// Run Tests on tblOut (GetTableOutput.TableData)

		// Check Table type (e.g. EXTERNAL_TABLE, VIRTUAL_VIEW, etc.).

		// Check Table Location
	}

	if _, err := A.GetTableMetadata(&athena.GetTableMetadataInput{
		DatabaseName: &dbName,
		TableName:    &tblName,
	}); err != nil {
		// Fail Tests - Table Not Found...
	} else {
		// Run Tests on tblMeta (GetTableMetadataOutput)

		// Check Column Equality...

		// Check PartitionKeys Equality...
	}

	// Check Outputs
	output := terraform.Output(
		t, terraformOptions, "alb_table",
	)

	assert.Equal(t, tblName, output)
}
