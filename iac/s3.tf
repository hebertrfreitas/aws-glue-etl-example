#create s3 bucket(storage for parquet file)
resource "aws_s3_bucket" "source_bucket" {
  bucket = "aws-glue-example-source-bucket-hebert"
}


#upload parquet file to s3 bucket
resource "aws_s3_bucket_object" "parquet_file" {
  bucket = aws_s3_bucket.source_bucket.id
  key    = "users-parquet"
  source = "output.parquet"
  etag   = filemd5("output.parquet")
}
