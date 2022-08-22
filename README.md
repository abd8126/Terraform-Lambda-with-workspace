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

The terraform will create the lambda functions, the api gateway and the authorizer for the token authorization