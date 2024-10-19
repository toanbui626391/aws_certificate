#create network insight path
INSIGHTS_PATH_ID=$(aws ec2 create-network-insights-path \
--source $INSTANCE_ID_1 --destination-port 22 \
--destination $INSTANCE_ID_2 --protocol tcp \
--output text --query NetworkInsightsPath.NetworkInsightsPathId)
#start network insight analysis
ANALYSIS_ID_1=$(aws ec2 start-network-insights-analysis \
--network-insights-path-id $INSIGHTS_PATH_ID --output text \
--query NetworkInsightsAnalysis.NetworkInsightsAnalysisId)
#get analysis result
aws ec2 describe-network-insights-analyses \
--network-insights-analysis-ids $ANALYSIS_ID_1
#fix network config with by attach ec2 instance with security group
aws ec2 authorize-security-group-ingress \
--protocol tcp --port 22 \
--source-group $INSTANCE_SG_ID_1 \
--group-id $INSTANCE_SG_ID_2
#rerun the analysis
ANALYSIS_ID_2=$(aws ec2 start-network-insights-analysis \
--network-insights-path-id $INSIGHTS_PATH_ID --output text \
--query NetworkInsightsAnalysis.NetworkInsightsAnalysisId)
#get the analysis result
aws ec2 describe-network-insights-analyses \
--network-insights-analysis-ids $ANALYSIS_ID_2
#check network configuration
#get private ip address of instance 2
aws ec2 describe-instances --instance-ids $INSTANCE_ID_2 \
--output text \
--query Reservations[0].Instances[0].PrivateIpAddress
#start ssm seesion at instance 1
aws ssm start-session --target $INSTANCE_ID_1
#install ncat util
sudo yum -y install nc
#ssh to instance 2 from instance 1 through port 22
nc -vz $INSTANCE_IP_2 22