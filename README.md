# Dr. Myo-Life Infrastructure (Ver 2.1)

Terraform으로 구성된 AWS 인프라 - 이미지 가공 및 회원가입 알림 시스템

## 아키텍처 개요

- **이미지 가공 파이프라인**: S3 → SNS → SQS → Lambda (Pillow Layer) → S3
- **회원가입 알림**: Cognito Post Confirmation → Lambda → SNS → Email
- **비용 최적화**: S3 Lifecycle Policy (optimized/ 경로: Standard → Standard-IA → Glacier)

## 리소스 구성

### Networking
- VPC: 192.168.10.0/24
- Public Subnet: 192.168.10.0/25

### Storage
- Original Bucket: ruokat-original-651109015678
- Processed Bucket: ruokat-processed-651109015678
- Lifecycle: optimized/ (1일 후 IA, 30일 후 Glacier)

### Messaging
- SNS Topics: ruokat-image-topic, ruokat-auth-topic
- SQS Queue: ruokat-image-queue (Visibility Timeout: 30s)
- Email Subscription: ruokat-auth-topic에 이메일 구독 설정

### Compute
- Lambda 1: ruokat-image-worker-iac (이미지 가공)
  - 저장 경로: backups/, thumbnails/, optimized/
- Lambda 2: ruokat-auth-notifier (가입 알림)
  - Subject: [R U OKat] 회원가입을 진심으로 축하드립니다!
  - Body: 안녕하세요, 집사님! 고양이와 함께하는 행복한 생활, Dr. Myo-Life에 오신 것을 환영합니다. 지금 바로 고양이 사진을 업로드하고 관리해보세요!
- Layer: Pillow (Python 3.12)

### Identity
- Cognito User Pool: ruokat-user-pool

## 배포 방법

### 1. 이메일 주소 설정
terraform.tfvars 파일에서 admin_email을 실제 이메일 주소로 변경:
```hcl
admin_email = "your-email@example.com"
```

### 2. 초기화
```bash
terraform init
```

### 3. 계획 확인
```bash
terraform plan
```

### 4. 배포
```bash
terraform apply
```

### 5. 이메일 구독 확인
배포 후 admin_email로 AWS SNS 구독 확인 이메일이 발송됩니다. 이메일의 "Confirm subscription" 링크를 클릭하세요.

### 6. 리소스 삭제
```bash
terraform destroy
```

## 테스트 방법

### 이미지 가공 테스트
```bash
aws s3 cp test-image.jpg s3://ruokat-original-651109015678/
```

처리된 이미지 확인:
- s3://ruokat-processed-651109015678/backups/
- s3://ruokat-processed-651109015678/thumbnails/
- s3://ruokat-processed-651109015678/optimized/

### 회원가입 테스트
Cognito User Pool에서 사용자 등록 후 이메일 확인

## 주의사항

- AWS 계정 ID: 651109015678
- Region: ap-northeast-2 (Seoul)
- Lambda Layer는 외부 ARN 사용 (Klayers Pillow)
- SNS 이메일 구독은 반드시 확인 필요
