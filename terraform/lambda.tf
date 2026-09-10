resource "aws_lambda_function" "ingest" {
  function_name = "energyiq-ingest"
  role          = aws_iam_role.energyiq_ingest.arn
  runtime       = "python3.14"
  handler       = "lambda_function.lambda_handler"

  timeout     = 3
  memory_size = 128

  filename         = "../lambda/ingest.zip"
  source_code_hash = filebase64sha256("../lambda/ingest.zip")

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }
}

resource "aws_lambda_function" "processor" {
  function_name = "energyiq-processor"
  role          = aws_iam_role.energyiq_processor.arn
  runtime       = "python3.14"
  handler       = "lambda_function.lambda_handler"

  timeout     = 30
  memory_size = 128

  filename         = "../lambda/processor.zip"
  source_code_hash = filebase64sha256("../lambda/processor.zip")

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_group_ids = [
      aws_security_group.lambda.id
    ]
  }
}