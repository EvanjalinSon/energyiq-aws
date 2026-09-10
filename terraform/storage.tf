resource "aws_dynamodb_table" "energy_readings" {
  name         = "EnergyReadings"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "meter_id"
  range_key = "timestamp"

  attribute {
    name = "meter_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

resource "aws_sqs_queue" "energyiq_reading_queue" {
  name             = "energyiq-reading-queue"
  max_message_size = 1048576
}

resource "aws_kms_key" "energyiq_s3" {
  description = "KMS key for encrypting EnergyIQ S3 data"
}

resource "aws_kms_alias" "energyiq_s3" {
  name          = "alias/energyiq-s3-key"
  target_key_id = aws_kms_key.energyiq_s3.key_id
}