📑 Infrastructure Specification: Project Dr. Myo-Life (Ver 2.1 - 완결본)
1. 프로젝트 개요
목적: S3 이미지 3종 자동 가공(비동기) 및 Cognito 회원가입 완료 시 환영 이메일 자동 발송 시스템 구축.

환경: AWS Seoul Region (ap-northeast-2), Terraform, Python 3.12.

2. 세부 리소스 요구사항
A. Networking: VPC(192.168.10.0/24), Public Subnet(192.168.10.0/25).

B. Storage (S3):

Origin: ruokat-original-651109015678

Processed: ruokat-processed-651109015678

수명주기(Lifecycle): optimized/ 경로 객체는 생성 1일 후 Standard-IA, 30일 후 Glacier 전환.

C. Messaging (SNS & SQS):

SNS Topic 1 (Image): ruokat-image-topic (S3 알림 수신용)

SNS Topic 2 (Auth): ruokat-auth-topic (가입 알림용)

Subscription: 사용자 이메일 주소를 Protocol: Email로 이 토픽에 구독 설정.

SQS Queue: ruokat-image-queue (Visibility Timeout: 30s).

D. Cognito:

User Pool: ruokat-user-pool

Trigger: Post Confirmation 이벤트 발생 시 ruokat-auth-notifier 람다 호출.

3. Lambda 로직 및 메시지 명세
가. 이미지 가공 (lambda_function.py)

동작: SQS 메시지 파싱 후 Pillow를 사용하여 아래 경로에 저장.

저장 경로: backups/(원본), thumbnails/(128x128), optimized/(Q:30).

나. 가입 알림 (auth_notifier.py)

이메일 내용:

Subject: [R U OKat] 회원가입을 진심으로 축하드립니다!

Body: 안녕하세요, 집사님! 고양이와 함께하는 행복한 생활, Dr. Myo-Life에 오신 것을 환영합니다. 지금 바로 고양이 사진을 업로드하고 관리해보세요!

동작: Cognito 이벤트를 받아 위 내용을 ruokat-auth-topic으로 Publish.