provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_s3_bucket" "task_s3" {
  bucket = "task_s3"
  acl    = "private"
}

resource "aws_db_instance" "task_rds" {
  identifier             = "task_rds"
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  name                   = "task_db"
  username               = "vishwesh"
  password               = "vishwesh"
  publicly_accessible    = false
  skip_final_snapshot    = true
}

# Define the IAM role for Lambda function
resource "aws_iam_role" "task_lambda" {
  name = "task_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_rds_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  roles      = [aws_iam_role.task_lambda.name]
}

# Create an ECR repository
resource "aws_ecr_repository" "lambda_repository" {
  name = "lambda-repository"
}

resource "aws_lambda_function" "your_lambda_function" {
  function_name    = "task_lambda_function"
  role             = aws_iam_role.task_lambda.arn
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.9"
  timeout          = 60
  memory_size      = 128
  image_uri        = aws_ecr_repository.lambda_repository.repository_url
  image_config {
    command = ["python3", "main.py"]
  }
  environment {
    variables = {
      DB_HOST     = aws_db_instance.task_rds.endpoint
      DB_NAME     = aws_db_instance.task_rds.name
      DB_USERNAME = aws_db_instance.task_rds.username
      DB_PASSWORD = aws_db_instance.task_rds.password
    }
  }
}

# Output the Lambda function name
output "lambda_function_name" {
  value = aws_lambda_function.your_lambda_function.function_name
}
