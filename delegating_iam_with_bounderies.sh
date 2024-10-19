#get the current principle (user) arn (aws resource name)
PRINCIPAL_ARN=$(aws sts get-caller-identity --query Arn --output text)
#use sed to replace principle value with in policy file
sed -e "s|PRINCIPAL_ARN|${PRINCIPAL_ARN}|g" \
assume-role-policy-template.json > assume-role-policy.json
#create a role with assum policy -> which principle can assume that role
ROLE_ARN=$(aws iam create-role --role-name AWSCookbook105Role \
--assume-role-policy-document file://assume-role-policy.json \
--output text --query Role.Arn)
#define policy or permissions with boundary-policy-template.json
#replace account id with sed command
sed -e "s|AWS_ACCOUNT_ID|${AWS_ACCOUNT_ID}|g" \
boundary-policy-template.json > boundary-policy.json
#create policy from policy file
aws iam create-policy --policy-name AWSCookbook105PB \
--policy-document file://boundary-policy.json
#define normal policy at policy.json
#replace account id with set
sed -e "s|AWS_ACCOUNT_ID|${AWS_ACCOUNT_ID}|g" \
policy-template.json > policy.json
#attache policy
aws iam attach-role-policy --policy-arn \
arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSCookbook105Policy \
--role-name AWSCookbook105Role

#test, using grep to get credential and then cut to get credential
creds=$(aws --output text sts assume-role --role-arn $ROLE_ARN \
--role-session-name "AWSCookbook105" | \
grep CREDENTIALS | cut -d " " -f2,4,5)
export AWS_ACCESS_KEY_ID=$(echo $creds | cut -d " " -f2)
export AWS_SECRET_ACCESS_KEY=$(echo $creds | cut -d " " -f4)
export AWS_SESSION_TOKEN=$(echo $creds | cut -d " " -f5)