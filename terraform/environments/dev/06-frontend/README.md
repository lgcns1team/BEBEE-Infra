# Frontend Infrastructure (CloudFront + S3)

프론트엔드 정적 웹사이트 호스팅을 위한 AWS 인프라 구성

## 구성 요소

- **S3 Bucket**: 정적 파일 저장소
  - 버전 관리 활성화
  - 서버 측 암호화 (AES256)
  - Public Access 차단 (CloudFront를 통해서만 접근)

- **CloudFront Distribution**: CDN
  - HTTPS 리다이렉션
  - Gzip 압축 활성화
  - SPA 라우팅 지원 (404/403 → index.html)
  - Origin Access Control (OAC) 사용

- **S3 Logs Bucket**: CloudFront 액세스 로그 저장

## 배포 방법

### 1. Terraform 초기화

```bash
cd terraform/environments/dev/06-frontend
terraform init
```

### 2. 리소스 확인

```bash
terraform plan
```

### 3. 리소스 생성

```bash
terraform apply
```

### 4. CloudFront URL 확인

```bash
terraform output cloudfront_url
```

## 프론트엔드 배포

### AWS CLI를 사용한 배포

```bash
# S3 버킷 이름 확인
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# 빌드된 프론트엔드 파일 업로드 (예: build 또는 dist 디렉토리)
aws s3 sync ./build s3://$BUCKET_NAME --delete

# CloudFront 캐시 무효화
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

### GitHub Actions를 사용한 자동 배포 예시

```yaml
name: Deploy Frontend

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build
        run: npm run build

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-2

      - name: Deploy to S3
        run: |
          aws s3 sync ./build s3://bebee-dev-frontend --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
```

## Outputs

- `cloudfront_url`: 프론트엔드 접속 URL
- `cloudfront_distribution_id`: CloudFront Distribution ID (캐시 무효화 시 사용)
- `s3_bucket_name`: S3 버킷 이름 (파일 업로드 시 사용)

## 주의사항

- CloudFront 배포는 생성/수정 시 15-20분 정도 소요됩니다
- 파일 업데이트 후 캐시 무효화를 하지 않으면 이전 버전이 표시될 수 있습니다
- 커스텀 도메인을 사용하려면 ACM 인증서와 Route53 설정이 필요합니다