#create security group
SG_ID=$(aws ec2 create-security-group \
--group-name AWSCookbook205Sg \
--description "Instance Security Group" --vpc-id $VPC_ID \
--output text --query GroupId)
#attach security group to ec2 instance
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID_1 \
--groups $SG_ID
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID_2 \
--groups $SG_ID
#add ingression rule to security group
aws ec2 authorize-security-group-ingress \
--protocol tcp --port 22 \
--source-group $SG_ID \
--group-id $SG_ID \
#validate
#get ip address for instance 2
aws ec2 describe-instances --instance-ids $INSTANCE_ID_2 \
--output text \
--query Reservations[0].Instances[0].PrivateIpAddress
#start session with instance 1
aws ssm start-session --target $INSTANCE_ID_1
#install netcat util
sudo yum -y install nc
#test ssh connection to instance 2 from instance 1
nc -vz $INSTANCE_IP_2 22