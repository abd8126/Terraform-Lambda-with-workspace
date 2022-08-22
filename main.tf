provider "aws" {
   region = var.region
  
}

locals {

  instance_name = "${terraform.workspace}-test"

}

resource "random_id" "id" {
  byte_length = 8
}

data "archive_file" "file_zip" {
    type          = "zip"
    source_file   = "functions/lambda_function.py"
    output_path   = "lambda_function.zip"
}

data "archive_file" "authentication_zip" {
    type          = "zip"
    source_file   = "functions/lambda_authentication.py"
    output_path   = "lambda_authentication.zip"
}


resource "aws_lambda_function" "lambda" {
	function_name = "cw356_lambda_function-${random_id.id.hex}"
  filename         = "lambda_function.zip"

  source_code_hash = "${data.archive_file.file_zip.output_base64sha256}"
   
  handler = "lambda_function.handler"
  runtime = "python3.7"

   role = aws_iam_role.lambda_role.arn
}



resource "aws_lambda_function" "authentication" {
  function_name = "cw356_lambda_authentication-${random_id.id.hex}"
  filename         = "lambda_authentication.zip"

  source_code_hash = "${data.archive_file.authentication_zip.output_base64sha256}"
   
  handler = "lambda_authentication.lambda_handler"
  runtime = "python3.7"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      token = var.api_token
    }
  }
}




resource "aws_iam_role" "lambda_role" {
   name = "cw356_lambda_role-${random_id.id.hex}"
   
   managed_policy_arns = [ aws_iam_policy.log_policy.arn ]
   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}


resource "aws_iam_policy" "log_policy" {
  name = "cw356_lambda_policy-${random_id.id.hex}"
  

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:*", "s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}



resource "aws_api_gateway_rest_api" "apiLambda" {
  name        = "cw356_api_gateway-${random_id.id.hex}"
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                   = "cw356_authorizer-${random_id.id.hex}"
  rest_api_id            = aws_api_gateway_rest_api.apiLambda.id
  authorizer_uri         = aws_lambda_function.authentication.invoke_arn
  type                   = "TOKEN"
}


resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxyMethod" {
   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
   resource_id   = aws_api_gateway_resource.proxy.id
   authorizer_id = aws_api_gateway_authorizer.authorizer.id
   http_method   = "ANY"
   authorization = "CUSTOM"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_method.proxyMethod.resource_id
   http_method = aws_api_gateway_method.proxyMethod.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda.invoke_arn
}



resource "aws_api_gateway_deployment" "apideploy" {
   depends_on = [
     aws_api_gateway_integration.lambda,
   ]

   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   stage_name  = var.api_gateway_stage_name
}


resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda.function_name
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*"
}


output "base_url" {
  value = aws_api_gateway_deployment.apideploy.invoke_url
}

output "api_token" {
  value = "token-${random_id.id.hex}"
}