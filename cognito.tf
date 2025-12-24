# [1] 사용자 풀 설정: 이메일 인증 방식 및 람다 트리거 연결
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"
   
  username_attributes =  ["email"]

  auto_verified_attributes = ["email"]

  # 💡 추가: 사용자가 가입 시 '코드'로 이메일을 인증하도록 설정
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "[R U OKat] 인증 코드를 확인해주세요"
    email_message        = "안녕하세요! 아래 인증 코드를 입력하여 가입을 완료해주세요: {####}"
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # 💡 가입 완료(Confirm) 직후 알림 람다 호출
  lambda_config {
    post_confirmation = aws_lambda_function.auth_notifier.arn
  }

  tags = {
    Name = "${var.project_name}-user-pool"
  }
}

# [2] 앱 클라이언트 설정: 로그인 페이지 및 가입 버튼 활성화
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # 💡 추가: 로그인 페이지(Hosted UI) 사용을 위한 필수 설정
  callback_urls                        = ["https://example.com"] # 테스트용 임시 주소
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# [3] 추가: 로그인 페이지용 도메인 주소 만들기
resource "aws_cognito_user_pool_domain" "main" {
  # 💡 전 세계에서 고유한 도메인 이름을 위해 계정 ID를 뒤에 붙였습니다.
  domain       = "${var.project_name}-auth-${var.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# [4] 람다 권한: Cognito가 알림 람다를 깨울 수 있도록 허용
resource "aws_lambda_permission" "cognito_trigger" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_notifier.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.main.arn
}