# Structure Folder

```
.
├── environment
│   ├── environment.tfvars
├── functions
│   ├── index.py
│   ├── lambda_function.py
├── main.tf
├── variables.tf
└── README.md
```

## Variables

```
Edit the file environment.tfvars with the variables for the terraform.
```

## Functions

```
The functions have to be in the files folder, because the terraform get the code from this folder.
The  function lambda_function.py corresponds to the authentication lambda function, and the index.py is your code
```

## Terraform


To execute the terraform just run the commands:
```
terraform init
terraform workspace new [workspace_name]
terraform workspace select [workspace_name] //For switching to another workspace
terraform plan -var-file="environment/environment.tfvars"
terraform apply -var-file="environment/environment.tfvars" //for creating the infrastracture

```

We have add API-Gateway Module in Module Folder which is called in api-gateway.tf (which is avavilbe in terraform/deployments tenant-infra-pipelines).

- From Line 14-25: We are creating the Zip file of Lambda Function which is in deployment folder.

- From Line 27-37: We are creating the lambda function and Archive our Lambda Function and excute with the iam role .

- From Line 39-55: Autauthentication
of created Lambda function and generate a token for autauthentication of Lambda with the role.

- From Line 36-77: Mapping the IAM Role with Lambda function and Created the Policy to access the Lambda

- From Line 79-94: Creating the log Policy for S3 to store the logs of Lambda Function.

- From Line 96-115: Creating the IAM Role for APIGLambdaAllowRole and also creating the Policy

- From Line 134-251 : We are creating a Sub-domain and ACM Certificate for sub-domain and after creation we are attaching the Created Lambda Function with Sub-domain and in Lambda we are also defining the Stage.



