import json
import boto3
import os

sns = boto3.client('sns')

def lambda_handler(event, context):
    """
    Cognito Post Confirmation Trigger
    회원가입 완료 시 SNS를 통해 환영 메시지 발송
    """
    try:
        user_email = event['request']['userAttributes'].get('email', 'Unknown')
        
        topic_arn = os.environ.get('SNS_TOPIC_ARN')
        
        subject = "[R U OKat] 회원가입을 진심으로 축하드립니다!"
        message = "안녕하세요, 집사님! 고양이와 함께하는 행복한 생활, Dr. Myo-Life에 오신 것을 환영합니다. 지금 바로 고양이 사진을 업로드하고 관리해보세요!"
        
        sns.publish(
            TopicArn=topic_arn,
            Subject=subject,
            Message=message
        )
        
        print(f"✅ Welcome email sent to {user_email}")
        
        return event
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return event
