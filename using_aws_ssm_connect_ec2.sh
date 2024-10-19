#create role with assume policy which allow ec2 to assum that role
ROLE_ARN=$(aws iam create-role --role-name AWSCookbook106SSMRole \
--assume-role-policy-document file://assume-role-policy.json \
--output text --query Role.Arn)
#attach policy to role
aws iam attach-role-policy --role-name AWSCookbook106SSMRole \
--policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
#create instance profile
aws iam create-instance-profile \
--instance-profile-name AWSCookbook106InstanceProfile
#add role to instance profile
aws iam add-role-to-instance-profile \
--role-name AWSCookbook106SSMRole \
--instance-profile-name AWSCookbook106InstanceProfile
#get latest machine image
AMI_ID=$(aws ssm get-parameters --names \
/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
--query 'Parameters[0].[Value]' --output text)
#create ec2 instance from instance profile
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID \
--count 1 \
--instance-type t3.nano \
--iam-instance-profile Name=AWSCookbook106InstanceProfile \
--subnet-id $SUBNET_1 \
--security-group-ids $INSTANCE_SG \
--metadata-options \
HttpTokens=required,HttpPutResponseHopLimit=64,HttpEndpoint=enabled \
--tag-specifications \
'ResourceType=instance,Tags=[{Key=Name,Value=AWSCookbook106}]' \
'ResourceType=volume,Tags=[{Key=Name,Value=AWSCookbook106}]' \
--query Instances[0].InstanceId \
--output text)
#get instance id
aws ssm describe-instance-information \
--filters Key=ResourceType,Values=EC2Instance \
--query "InstanceInformationList[].InstanceId" --output text
#connect to the instance
aws ssm start-session --target $INSTANCE_ID
