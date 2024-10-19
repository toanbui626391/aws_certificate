#password policy is effect at aws level we do not need to attach to role like policy
#create password policy
aws iam update-account-password-policy \
--minimum-password-length 32 \
--require-symbols \
--require-numbers \
--require-uppercase-characters \
--require-lowercase-characters \
--allow-users-to-change-password \
--max-password-age 90 \
--password-reuse-prevention true
#create-group
aws iam create-group --group-name AWSCookbook103Group
#attach-role-policy
aws iam attach-group-policy --group-name AWSCookbook103Group \
--policy-arn arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess
#create iam user
aws iam create-user --user-name awscookbook103user
#generate random string as password
RANDOM_STRING=$(aws secretsmanager get-random-password \
--password-length 32 --require-each-included-type \
--output text \
--query RandomPassword)
#create login profile or mapping between user and password
aws iam create-login-profile --user-name awscookbook103user \
--password $RANDOM_STRING
#add user to a group
aws iam add-user-to-group --group-name AWSCookbook103Group \
--user-name awscookbook103user
#check password policy is active or not
aws iam get-account-password-policy