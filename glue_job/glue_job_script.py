import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from datetime import date

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

job.init(args["JOB_NAME"], args)

current_date = date.today().strftime("%Y-%m-%d %H:%M:%S")

# Script generated for node S3 bucket
s3_data_frame = glueContext.create_dynamic_frame.from_catalog(
    database="s3_database_input",
    table_name="s3_input_table",
    transformation_ctx="S3bucket_node1",
)


def map_s3_model_to_dynamo_model(item):
    item["datetime"] = current_date
    return item


mapped = Map.apply(frame=s3_data_frame, f=map_s3_model_to_dynamo_model)

mapped.toDF().show()

# Script generated for node ApplyMapping
ApplyMapping_node2 = ApplyMapping.apply(
    frame=s3_data_frame,
    mappings=[
        ("username", "string", "username", "string"),
        ("last_access", "string", "last_access", "string"),
        ("is_admin", "long", "is_admin", "long"),
        ("app_version", "string", "app_version", "string"),
    ],
    transformation_ctx="ApplyMapping_node2",
)

print("DESCREVENDO RETORNO.....")
ApplyMapping_node2.printSchema()

print("TERMINEI.....")

# # Script generated for node S3 bucket
# S3bucket_node3 = glueContext.write_dynamic_frame.from_options(
#     frame=ApplyMapping_node2,
#     connection_type="s3",
#     format="json",
#     connection_options={
#         "path": "s3://aws-glue-example-source-bucket-hebert/",
#         "partitionKeys": [],
#     },
#     transformation_ctx="S3bucket_node3",
# )

glueContext.write_dynamic_frame.from_options(
    frame=mapped,
    connection_type="dynamodb",
    connection_options={
        "dynamodb.output.tableName": "TargetTable",
        "dynamodb.throughput.write.percent": "1.0"
    }
)

job.commit()
