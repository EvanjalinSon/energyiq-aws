resource "aws_iam_role" "energyiq_ingest" {
  name = "energyiq-ingest-role-cyfv1mz0"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "energyiq_ingest" {
  name = "AWSLambdaBasicExecutionRole-427a8762-9baf-4dd0-a4f9-2838a83a65aa"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:us-east-1:075729033948:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:us-east-1:075729033948:log-group:/aws/lambda/energyiq-ingest:*"
      },
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = "arn:aws:sqs:us-east-1:075729033948:energyiq-reading-queue"
      },
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:us-east-1:075729033948:parameter/energyiq/sqs/reading-queue-url"
      }
    ]
  })
}
resource "aws_iam_role" "energyiq_processor" {
  name = "energyiq-processor-role-odltgtfs"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "energyiq_processor" {
  name = "AWSLambdaBasicExecutionRole-800a7835-b4c6-4060-906d-9581bbd5c62c"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:us-east-1:075729033948:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:075729033948:log-group:/aws/lambda/energyiq-processor:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "arn:aws:sqs:us-east-1:075729033948:energyiq-reading-queue"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:075729033948:table/EnergyReadings"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::energyiq-data-key-bucket/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:decrypt"
        ]
        Resource = "arn:aws:kms:us-east-1:075729033948:key/00350365-fdea-49f6-a365-325904f13813"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:075729033948:secret:energyiq/demo/api-D2s6a7"
      }
    ]
  })
}