import boto3
import base64


def handler(event, context):
    client = boto3.client('s3')
    bucket_name ='all-dev-tenant-bucket'
    file_name= event['pathParameters']['proxy']

    print(f"Bucket name: {bucket_name}")
    print(f"File name: {file_name}")
   
    
    fileObject = client.get_object(Bucket=bucket_name, Key=file_name)
    
    print("Object retrieved from s3")

    file_content = fileObject["Body"].read()
    
    print(bucket_name, file_name)
    
    return base64.b64encode(file_content)