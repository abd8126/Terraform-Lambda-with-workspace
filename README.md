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

# Steps to find the Created Resources in AWS Console
- Step-1 Go to API Gateway which is created as tenant Name (Ex- api_gateway-user1)
- Step-2 Select the API Gateway -> Go to Stages and select the stage (Ex- dev-user1) -> Select invoke Url
- Step-3 For Token: Go to AWS Lambda FUnction -> Select Craeted Function Name (Ex- lambda_authentication-user1) -> Select the Configuration -> Select Environment variables 

----------------------------------------------------------------------------------------------------------------------------------------------------
## API Gateway Deployment Pipeline



API Gateway terraform script will call the API Module which is available in modules/api-gateway-deployments directory.



This executes once for each tenant configured in the TF_VAR_TENANT github secret



- Creates the Lambda Zip



- Creates Authorizer lambda zip for Authentication



- Assign IAM Role for Lambda



- Maps the IAM Role with Lambda Function



- Creates API Gateway authorizer_credentials of APIGLambdaAllowRole



- Deploys the API with Lambda



## Extracting API Gaetway URLs aand authentication tokens for each tenant



For each tenant configured in the TF_VAR_TENANT github secret, there is separate api gateway and lambda infrastructure created by the script.



If the TF_VAR_TENANT has the following list [tenant1, tenant2, tenant3] (or if more are added in the future), to get the api gateway domains and authentication tokens for each tenant, follow below steps :



To fetch the api gateway domain and authentication token for tenant1 :



1. Login to the AWS account where the Github Action Pipeline creates its resources.



### Fetching API Gateway URL



1. Go to API Gateway and open the Api which is created as tenant Name (Ex- api_gateway-tenant1)

2. Select the API Gateway -> Go to Stages and select the stage (Ex- dev-tenant1) -> Select invoke Url

3. This will show the API Endpoint URL for that tenant which they need to invoke



### Fetching Authentication Tokens



1. Go to Lambda in AWS and open the function which is created as tenant Name (Ex- ambda_authentication-tenant1)

2. Select the Configuration Tab in the function

3. Select Environment variables from the left hand menu

4. This should show the authentication token (to be paased as Authorization header in the API Gateway call) for that tenant
