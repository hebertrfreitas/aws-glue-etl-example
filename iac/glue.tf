//banco de dados no glue
resource "aws_glue_catalog_database" "s3_database_input" {
  name = "s3_database_input"
}

//table que representa os metadados do input no S3
//também poderia ser gerada através de um crawler
resource "aws_glue_catalog_table" "s3_input_table" {
  name          = "s3_input_table"
  database_name = aws_glue_catalog_database.s3_database_input.name

  table_type = "EXTERNAL_TABLE"

  #   parameters = {
  #     EXTERNAL = "TRUE"
  #     "parquet.compression" = "SNAPPY"
  #   }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.source_bucket.bucket}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "username"
      type = "string"
    }

    columns {
      name = "email"
      type = "string"
    }

    columns {
      name = "last_access"
      type = "string"
    }

    columns {
      name = "is_admin"
      type = "bigint"
    }

    columns {
      name = "app_version"
      type = "string"
    }

  }
}

#upload a python job script to s3
resource "aws_s3_bucket_object" "s3_upload_glue_job" {
  bucket = aws_s3_bucket.source_bucket.id
  key    = "glue_job_script.py"
  source = "../glue_job/glue_job_script.py"
  etag   = filemd5("../glue_job/glue_job_script.py")
}


#default role for glue (this policy is extracted to aws console, original policy name is AWSGlueServiceRole)
# resource "aws_iam_role" "glue_job_iam_role" {
#   name = "glue_job_s3_to_dynamo-role"
#   assume_role_policy = 
#   policy = 
# }


resource "aws_glue_job" "glue_job" {
  name     = "glue_job_s3_to_dynamo"
  role_arn = aws_iam_role.example.arn
  
  default_arguments = {
    "--job-language" = "python"
  }


  command {
    script_location = "s3://${aws_s3_bucket_object.s3_upload_glue_job.bucket}/${aws_s3_bucket_object.s3_upload_glue_job.key}"
    python_version = 3
  }
}

