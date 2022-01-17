package test

// Terraform Tests w. https://github.com/gruntwork-io/terratest
import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/athena"
	"github.com/aws/aws-sdk-go/service/glue"
	"github.com/aws/aws-sdk-go/service/s3"
	ttaws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	log "github.com/sirupsen/logrus"
	"github.com/stretchr/testify/assert"
)

var (
	uniqueID          = strings.ToLower(random.UniqueId())
	athenaBucketName  = fmt.Sprintf("terratestathena%s", uniqueID)
	athenaDBName      = fmt.Sprintf("terratest_athena_%s", uniqueID)
	svcLogsBucketName = "tf-athena-svc-logs-profound-seagull"
	albTblName        = "alb"
)

func init() {
	// Log as JSON instead of the default ASCII formatter.
	log.SetFormatter(&log.JSONFormatter{})

	// Output to stdout instead of the default stderr
	// Can be any io.Writer, see below for File example
	log.SetOutput(os.Stdout)

	// Only log the warning severity or above.
	log.SetLevel(log.WarnLevel)
}

func TestTerraformALB(t *testing.T) {

	// Create a Glue client with additional configuration
	awsRegion := ttaws.GetRandomStableRegion(t, nil, nil)

	sess := session.Must(session.NewSession())

	// Retryable errors in terraform testing - Init and Run
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/alb-standard",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"svc_logs_bucket_name":             svcLogsBucketName,
			"athena_query_results_bucket_name": athenaBucketName,
			"aws_athena_database":              athenaDBName,
			"alb_logs_tbl_name":                albTblName,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// NOTE: Create Resources - The `alb` examples do not rely on terratest's aws module to
	// create a bucket or put a bucket policy, s3 resources are configured independently

	// Create Bucket for Athena DB
	defer func() {
		ttaws.EmptyS3Bucket(t, awsRegion, athenaBucketName)
		ttaws.DeleteS3Bucket(t, awsRegion, athenaBucketName)
	}()

	defer terraform.Destroy(t, terraformOptions)

	ttaws.CreateS3Bucket(t, awsRegion, athenaBucketName)

	terraform.InitAndApply(t, terraformOptions)

	//
	// Glue Tests - Check Glue Catalog
	//

	G := glue.New(
		sess, aws.NewConfig().WithRegion(awsRegion),
	)

	if tblOut, err := G.GetTable(&glue.GetTableInput{
		DatabaseName: &athenaDBName,
		Name:         &albTblName,
	}); err != nil {

		// Fail Tests Bluntly - Table Not Found...
		assert.Equal(
			t, false, true,
			fmt.Sprintf("Failed with Err (%v). Failed to locate target table (%s) in Glue Catalog", err, albTblName),
		)

	} else {

		// Check Table type (e.g. EXTERNAL_TABLE, VIRTUAL_VIEW, etc.).
		assert.Equal(
			t, "EXTERNAL_TABLE", *tblOut.Table.TableType,
			fmt.Sprintf("Table Type should be EXTERNAL_TABLE, got %s", *tblOut.Table.TableType),
		)

		// Check Table Parameters
		assert.Equal(
			t, "true", *(tblOut.Table.Parameters["projection.enabled"]),
		)

		// Check Partition Keys
		partitionKeys := []string{}
		for _, pk := range tblOut.Table.PartitionKeys {
			partitionKeys = append(partitionKeys, *pk.Name)
		}

		assert.Equal(
			t, []string{"account_id", "region", "date"}, partitionKeys,
		)
	}

	// Check via Glue -> Glue Partitions
	if tblPartitions, err := G.GetPartitions(&glue.GetPartitionsInput{
		DatabaseName: &athenaDBName,
		TableName:    &albTblName,
	}); err != nil {

		// Fail Tests Bluntly - Table Not Found...
		assert.Equal(
			t, true, false,
			fmt.Sprintf("Failed with Err (%v). failed to locate target table (%s) in Glue Catalog", err, tblPartitions),
		)

	} else {
		// Show Partitions; Expect valid response, but no items in List
		assert.Equal(
			t, []*glue.Partition([]*glue.Partition{}), tblPartitions.Partitions,
		)
	}

	//
	// Athena Tests - Check Athena MetaData
	//

	A := athena.New(
		sess, aws.NewConfig().WithRegion("us-east-1"),
	)

	if tblMeta, err := A.GetTableMetadata(&athena.GetTableMetadataInput{
		DatabaseName: &athenaDBName,
		TableName:    &albTblName,
	}); err != nil {

		// Fail Tests Bluntly - Table Not Found...
		assert.Equal(
			t, true, false,
			fmt.Sprintf("Failed to locate target table (%s) in Athena Metadata", albTblName),
		)

	} else {

		// Check TYPE == EXTERNAL_TABLE
		assert.Equal(
			t, tblMeta.TableMetadata.TableType, "EXTERNAL_TABLE",
			fmt.Sprintf("Table Type should be EXTERNAL, got %s", *tblMeta.TableMetadata.TableType),
		)

	}

	// Check Results in Athena Query Log Bucket - Should See Tests From Above!
	svc := s3.New(
		session.New(),
		&aws.Config{Region: aws.String(awsRegion)},
	)

	resp, err := svc.ListObjects(&s3.ListObjectsInput{
		Bucket: aws.String(athenaBucketName),
	})

	// Check No Error
	assert.NoError(t, err, "...")

	// Check there are query results in the bucket...
	assert.Greater(t, len(resp.Contents), 0)

}
