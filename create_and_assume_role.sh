"""
1.1 Creating and Assuming an IAM Role for Developer Access 
"""
#get user id or arn
PRINCIPAL_ARN=$(aws sts get-caller-identity --query Arn --output text)
#replace principle arn value to the template assume-role-policy-template.json and then create assume-role-policy.json
sed -e "s|PRINCIPAL_ARN|${PRINCIPAL_ARN}|g" \
assume-role-policy-template.json > assume-role-policy.json
#create a role with command aws iam create-role
ROLE_ARN=$(aws iam create-role --role-name AWSCookbook101Role \
--assume-role-policy-document file://assume-role-policy.json \
--output text --query Role.Arn)
#attach role-policy
aws iam attach-role-policy --role-name AWSCookbook101Role \
--policy-arn arn:aws:iam::aws:policy/PowerUserAccess
#assume role
aws sts assume-role --role-arn $ROLE_ARN \
--role-session-name AWSCookbook101