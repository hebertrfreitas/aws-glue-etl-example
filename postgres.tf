resource "random_password" "db_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers = {
    pass_version = 1
  }
}


#creating a secret manager to store db password
resource "aws_secretsmanager_secret" "pg_db_pass" {
  name = "postgres-db-password"
}

resource "aws_secretsmanager_secret_version" "db_pass_val" {
  secret_id     = aws_secretsmanager_secret.pg_db_pass.id
  secret_string = random_password.db_master_pass.result
}

#creating postgres instance to store the ETL result
resource "aws_db_instance" "postgres_output" {
  allocated_storage = 2
  engine            = "postgres"
  engine_version    = "12"
  instance_class    = "db.t3.micro"
  db_name           = "glue_output_db"
  username          = "hebert"
  password          = random_password.db_master_pass.result
}

