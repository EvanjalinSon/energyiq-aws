# EnergyIQ — AWS Serverless Energy Monitoring Platform

EnergyIQ is a production-style, serverless AWS application designed to collect, process, store, and monitor energy consumption readings from smart meters.

The project demonstrates practical implementation of **AWS serverless architecture, event-driven processing, security, networking, monitoring, Infrastructure as Code, and CI automation**.

---

## Architecture

```text
                         ┌───────────────┐
                         │ Client/Postman│
                         └───────┬───────┘
                                 │
                            POST /readings
                                 │
                                 ▼
                         ┌───────────────┐
                         │ API Gateway   │
                         │  energyiq-api │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │ Lambda        │
                         │ energyiq-     │
                         │ ingest        │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │ SQS           │
                         │ energyiq-     │
                         │ reading-queue │
                         └───────┬───────┘
                                 │
                         Event Source Mapping
                                 │
                                 ▼
                       ┌─────────────────┐
                       │ Lambda          │
                       │ energyiq-       │
                       │ processor       │
                       └───────┬─────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
                    ▼                     ▼
             ┌──────────────┐      ┌──────────────┐
             │  DynamoDB    │      │      S3      │
             │EnergyReadings│      │ Raw Readings │
             └──────────────┘      └──────────────┘
                                      │
                                      ▼
                                AWS KMS Encryption
```

---

## How It Works

1. A client sends an energy reading to the API Gateway `/readings` endpoint.
2. API Gateway invokes the `energyiq-ingest` Lambda.
3. The ingestion Lambda retrieves the SQS queue configuration from SSM Parameter Store.
4. The reading is sent to the `energyiq-reading-queue` SQS queue.
5. SQS triggers the `energyiq-processor` Lambda through an event source mapping.
6. The processor Lambda writes the structured reading to DynamoDB.
7. The processor Lambda also stores the raw reading as a JSON object in S3.
8. S3 data is encrypted using an AWS KMS customer-managed key.
9. CloudWatch provides logs, metrics, alarms, and monitoring.

---

## Sample Request

```json
{
  "meter_id": "METER001",
  "timestamp": "2026-09-09T10:00:00Z",
  "energy_kwh": 12.5
}
```

---

## AWS Services

| Service                                 | Purpose                                        |
| --------------------------------------- | ---------------------------------------------- |
| **Amazon API Gateway**                  | Exposes the energy reading API                 |
| **AWS Lambda**                          | Handles ingestion and asynchronous processing  |
| **Amazon SQS**                          | Provides asynchronous messaging and decoupling |
| **Amazon DynamoDB**                     | Stores structured energy readings              |
| **Amazon S3**                           | Stores raw JSON readings                       |
| **AWS KMS**                             | Encrypts S3 data                               |
| **AWS IAM**                             | Provides least-privilege access                |
| **AWS Secrets Manager**                 | Stores sensitive application information       |
| **AWS Systems Manager Parameter Store** | Stores application configuration               |
| **Amazon VPC**                          | Provides network isolation                     |
| **VPC Endpoints**                       | Provides private connectivity to AWS services  |
| **Amazon CloudWatch**                   | Logs, metrics, alarms, and dashboards          |
| **Amazon SNS**                          | Monitoring notifications                       |
| **Terraform**                           | Infrastructure as Code                         |
| **GitHub Actions**                      | Continuous integration                         |
| **GitHub OIDC**                         | Secure AWS authentication for CI               |

---

## Security

EnergyIQ implements security at multiple layers.

### IAM

Separate IAM roles are used for the ingestion and processor Lambda functions.

Permissions are restricted to the resources required by each function.

### Encryption

S3 objects are encrypted using a customer-managed AWS KMS key.

```text
alias/energyiq-s3-key
```

### Secrets Management

Sensitive application information is stored in AWS Secrets Manager rather than being hardcoded in the Lambda code.

### Parameter Store

Application configuration such as the SQS queue URL is stored in Systems Manager Parameter Store.

### Network Security

The processor Lambda runs inside private VPC subnets.

VPC endpoints provide private connectivity to required AWS services without requiring a NAT Gateway for those service connections.

---

## Infrastructure as Code

The AWS infrastructure is managed using Terraform.

```text
terraform/
├── main.tf
├── networking.tf
├── iam.tf
├── lambda.tf
├── storage.tf
├── monitoring.tf
├── variables.tf
└── outputs.tf
```

Terraform was used to bring the existing EnergyIQ infrastructure under Infrastructure as Code management.

The final Terraform plan returned:

```text
No changes. Your infrastructure matches the configuration.
```

---

## CI with GitHub Actions

GitHub Actions automatically validates Terraform changes on pushes and pull requests.

```text
Git Push / Pull Request
          ↓
    GitHub Actions
          ↓
 Terraform Format Check
          ↓
     Terraform Init
          ↓
   Terraform Validate
          ↓
     Terraform Plan
```

### AWS Authentication

GitHub Actions authenticates with AWS using **OIDC** instead of storing long-lived AWS access keys.

```text
GitHub Actions
      ↓
GitHub OIDC
      ↓
AWS IAM Role
      ↓
Temporary AWS Credentials
      ↓
Terraform
```

This reduces the security risks associated with storing permanent AWS credentials in CI/CD systems.

---

## Monitoring & Troubleshooting

Amazon CloudWatch is used for application observability.

Monitoring includes:

* Lambda execution logs
* Lambda errors
* Lambda metrics
* SQS activity
* CloudWatch alarms
* CloudWatch dashboard
* SNS notifications

### Practical Troubleshooting

Several real AWS issues were encountered and resolved during development, including:

* KMS permission failures
* Secrets Manager access failures from a VPC-based Lambda
* VPC endpoint connectivity issues
* Security Group configuration issues
* DynamoDB `Decimal` serialization
* JSON serialization/deserialization issues
* SQS batch-processing behavior
* IAM resource ARN mismatches

These troubleshooting scenarios helped validate the architecture beyond simple service configuration.

---

## Testing

The complete application flow was tested end-to-end.

### Test Input

```json
{
  "meter_id": "METER001",
  "timestamp": "2026-09-09T10:00:00Z",
  "energy_kwh": 12.5
}
```

### Validation

The reading was successfully verified in:

* ✅ API Gateway
* ✅ Ingestion Lambda
* ✅ SQS
* ✅ Processor Lambda
* ✅ DynamoDB
* ✅ S3
* ✅ KMS encryption
* ✅ CloudWatch

The same reading was successfully persisted in both **DynamoDB and S3**.

---

## Key Cloud Engineering Concepts Demonstrated

* Serverless architecture
* Event-driven architecture
* Asynchronous processing
* Loose coupling
* IAM least privilege
* KMS encryption
* Secrets management
* Parameter Store
* VPC networking
* Private subnets
* VPC endpoints
* Security Groups
* CloudWatch observability
* Terraform Infrastructure as Code
* Terraform state and resource import
* GitHub Actions
* GitHub OIDC
* AWS troubleshooting

---

## Project Outcome

EnergyIQ demonstrates a complete cloud-native workflow from API ingestion to asynchronous processing and persistent storage.

The project combines **AWS application development, cloud networking, security, observability, Infrastructure as Code, and CI automation** into a single practical implementation.

It was designed to simulate the type of architecture and operational considerations encountered in real-world Cloud Engineer environments.
