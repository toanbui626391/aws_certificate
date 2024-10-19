# create role with assume-role-policy or which principle can assume the role
aws iam create-role --assume-role-policy-document \
file://assume-role-policy.json --role-name AWSCookbook104IamRole
# attach-role-policy or associate role-name with permission or policy
aws iam attach-role-policy --role-name AWSCookbook104IamRole \
--policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
#test policy or test policy
aws iam simulate-principal-policy \
--policy-source-arn arn:aws:iam::$AWS_ACCOUNT_ARN:role/AWSCookbook104IamRole \
--action-names ec2:CreateInternetGateway
#test policy with an actino-names
aws iam simulate-principal-policy \
--policy-source-arn arn:aws:iam::$AWS_ACCOUNT_ARN:role/AWSCookbook104IamRole \
--action-names ec2:DescribeInstances