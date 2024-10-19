#create a key
KMS_KEY_ID=$(aws kms create-key --description "AWSCookbook107Key" \
--output text --query KeyMetadata.KeyId)
#create alias for the key
aws kms create-alias --alias-name alias/AWSCookbook107Key \
--target-key-id $KMS_KEY_ID
#enable key rotation
aws kms enable-key-rotation --key-id $KMS_KEY_ID
#enable ec2 encrypt by default
aws ec2 enable-ebs-encryption-by-default
#use key from kms for encryption
aws ec2 modify-ebs-default-kms-key-id \
--kms-key-id alias/AWSCookbook107Key
#check ec2 default encryption
aws ec2 get-ebs-encryption-by-default
#get ec2 default key
aws ec2 get-ebs-default-kms-key-id
#check key rotation status
aws kms get-key-rotation-status --key-id $KMS_KEY_ID