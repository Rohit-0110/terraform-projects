#!/bin/bash
bucket_name=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'terraform-web-app-bucket-')].Name" --output text);
STACKS=$(aws elasticbeanstalk list-available-solution-stacks --query 'SolutionStacks' --output text);
STACKS_NEWLINE=$(echo "$STACKS" | tr "\t" "\n");
LATEST_STACK=$(echo "$STACKS_NEWLINE" | grep "64bit Amazon Linux 2023.*running Node.js 20" | sort -V | tail -n 1);
echo "$LATEST_STACK";
aws elasticbeanstalk create-environment --application-name terraform-web-app --environment-name devm --solution-stack-name "$LATEST_STACK" --version-label v1 --option-settings file://options.json;
aws elasticbeanstalk create-application-version --application-name terraform-web-app --version-label v1 --source-bundle S3Bucket="$bucket_name",S3Key=app-v1.zip