import boto3
import json
import csv


def handler(event, context):
    s3 = boto3.resource('s3')
    bucket_name = 'all-dev-tenant-bucket' # Change for the namme of your bucket
    path = event['pathParameters']['proxy']
    file_name= path
    #file_name='SitCen/repository/run-datasink4-1-part-r-00000'
    content_object = s3.Object(bucket_name, file_name)
    file_content = content_object.get()['Body'].read().decode('UTF-8')
    
    fieldnames = []
    rows = []
    count = 0
    
    data = json.loads(file_content)
    print(data)
    
    with open("/tmp/file.csv", 'w') as f: 
        for item in data:
            print(item)
            if (type(data[item])) == str:
                fieldnames.append(item)
                rows.append((f'{item}', f'{data[item]}'))

            elif (type(data[item])) == dict:
                for dic in data[item]:
                    if (type(data[item][dic])) == str:
                        fieldnames.append(item + "_" + dic)
                        rows.append((f'{item + "_" + dic}', f'{data[item][dic]}'))
                    elif (type(data[item][dic])) == list:
                        for t in data[item][dic]:
                            fieldnames.append(item + "_" + dic)
                            rows.append((f'{item + "_" + dic}', f'{t}'))
            elif (type(data[item])) == list:
                fieldnames.append(item)
                rows.append((f'{item}', f'{data[item]}'))
        print(fieldnames)
        print(rows)

        wr = csv.DictWriter(f, fieldnames = fieldnames) 
        wr.writeheader()
        change_to_dict = dict(rows)
        wr.writerow(change_to_dict)
    
    with open("/tmp/file.csv", 'r') as G:
        dados = G.read()
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/csv"
        },
        "body": dados
    }
