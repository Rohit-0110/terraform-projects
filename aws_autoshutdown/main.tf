provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "AWSLambdaAutoShutdown"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "autoshutdown_policy" {
  name        = "lambda_autoshutdown_policy"
  path        = "/"
  description = "policy for autoshutdown lambda function"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Statement1",
          "Effect" : "Allow",
          "Action" : [
            "ec2:Describe*",
            "ec2:StopInstances"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Sid" : "Statement2",
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:GetMetricStatistics"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Sid" : "Statement3"
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : "arn:aws:logs:ap-south-1:520469265833:*"
        },
        {
          "Sid" : "Statement4"
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "arn:aws:logs:ap-south-1:520469265833:log-group:/aws/lambda/autoshutdown-Lambda-Function:*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "autoshutdown_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.autoshutdown_policy.arn
}

data "archive_file" "zip_autoshutdown" {
  type        = "zip"
  source_dir  = "/home/rohit/Documents/terraform/auto-shutdown"
  output_path = "/home/rohit/Documents/terraform/auto-shutdown/autoshutdown.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "/home/rohit/Documents/lambda/python/autoshutdown.zip"
  function_name = "autoshutdown-Lambda-Function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "autoshutdown.main"

  runtime = "python3.10"
  timeout = 150

  environment {
    variables = {
      TAG_KEY   = "cloudbox_version"
      TAG_VALUE = "1.0.0"
    }
  }
}
