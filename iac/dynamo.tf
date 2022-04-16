resource "aws_dynamodb_table" "target-table" {
  name           = "TargetTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "username"
  range_key      = "datetime"

  attribute {
    name = "username"
    type = "S"
  }

  attribute {
    name = "datetime"
    type = "S"
  }
}