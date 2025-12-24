# VPC Module

AWS VPC를 생성하는 재사용 가능한 Terraform 모듈입니다.

## 생성되는 리소스

- VPC
  - DNS hostname 지원
  - DNS resolution 지원

## 사용 예시

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "bebee-dev"
  vpc_cidr    = "10.0.0.0/16"

  tags = {
    Environment = "dev"
    Project     = "bebee"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | 리소스 이름 접두사 | string | - | yes |
| vpc_cidr | VPC CIDR 블록 | string | - | yes |
| tags | 공통 태그 | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR 블록 |
| vpc_arn | VPC ARN |

## 향후 확장 가능 항목

- Internet Gateway
- Public/Private Subnets
- NAT Gateway
- Route Tables
- VPC Endpoints