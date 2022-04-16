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






# resource "aws_iam_policy_document" "glue-crawler-s3-policy-document" {


#   statement {
#     version = "2012-10-17"
#     effect  = "Allow"
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject"
#     ]
#     resources = ["${aws_s3_bucket_object.parquet_file.arn}/*"]

#   }


# }






# resource "aws_iam_role" "aws-glue-role-s3-crawler" {
#   name = "AWSGlueServiceRole-s3_crawler_input"

#     assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "glue.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }  

# }


# resource "aws_glue_crawler" "s3_crawler_input" {
#   database_name = aws_glue_catalog_database.s3_database_input.name
#   name          = "s3_crawler_input"
#   role          = aws_iam_role.example.arn

#   s3_target {
#     path = "s3://${aws_s3_bucket.source_bucket.bucket}"
#   }
# }