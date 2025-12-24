import json
import boto3
import io
import urllib.parse
from PIL import Image

# [초기화] S3 클라이언트 선언
s3 = boto3.client('s3')

def lambda_handler(event, context):
    """
    S3 원본 업로드 이벤트를 감지하여 3가지 규격으로 자동 가공하는 함수
    1. 원본 백업 (Original)
    2. 썸네일 생성 (128x128)
    3. 저화질 압축본 (Quality 30%)
    """
    for record in event['Records']:
        try:
            # [Step 1] 메시지 분석: SQS -> SNS -> S3 이벤트 정보 추출
            sns_message = json.loads(record['body'])
            s3_event = json.loads(sns_message['Message'])
            
            for s3_record in s3_event.get('Records', []):
                source_bucket = s3_record['s3']['bucket']['name']
                source_key = urllib.parse.unquote_plus(s3_record['s3']['object']['key'])
                file_name = source_key.split('/')[-1]
                
                # [Step 2] 원본 데이터 로드
                response = s3.get_object(Bucket=source_bucket, Key=source_key)
                image_content = response['Body'].read()
                
                # 결과 저장 대상 버킷 (본인 계정 정보 확인)
                dest_bucket = 'ruokat-processed-651109015678'
                
                # [Step 3] Pillow 라이브러리를 활용한 이미지 가공
                img = Image.open(io.BytesIO(image_content))
                img_format = img.format if img.format else 'JPEG'

                # --- 작업 A: 원본 백업 저장 ---
                s3.put_object(
                    Bucket=dest_bucket, 
                    Key=f"backups/{file_name}", 
                    Body=image_content
                )

                # --- 작업 B: 썸네일 생성 (128x128) ---
                thumb_img = img.copy()
                thumb_img.thumbnail((128, 128))
                thumb_buffer = io.BytesIO()
                thumb_img.save(thumb_buffer, format=img_format)
                s3.put_object(
                    Bucket=dest_bucket, 
                    Key=f"thumbnails/{file_name}", 
                    Body=thumb_buffer.getvalue()
                )

                # --- 작업 C: 저화질 열화판 생성 (Quality 30%) ---
                low_q_buffer = io.BytesIO()
                img.save(low_q_buffer, format=img_format, quality=30)
                s3.put_object(
                    Bucket=dest_bucket, 
                    Key=f"optimized/{file_name}", 
                    Body=low_q_buffer.getvalue()
                )
                
                print(f"✅ Success: {file_name} 3-Way split complete!")

        except Exception as e:
            print(f"❌ Error: {str(e)}")
            raise e

    return {'statusCode': 200, 'body': 'Image Processing Success!'}