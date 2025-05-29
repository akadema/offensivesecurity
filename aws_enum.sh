#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
# Syntax ./aws_enum.sh {aws_profile}

aws_profile="$1" 
echo "making folder: $aws_profile"
mkdir "$aws_profile"
echo "Using AWS profile: $aws_profile"
echo -e "\n"

echo "=== Who am I? ==="
username=$(aws sts get-caller-identity --query Arn --profile $aws_profile --output text | awk -F'/' '{print $2}')
userid=$(aws sts get-caller-identity --query UserId --profile $aws_profile --output text)
account=$(aws sts get-caller-identity --query Account --profile $aws_profile --output text)
userarn=$(aws sts get-caller-identity --query Arn --profile $aws_profile --output text)


echo "Username: $username"
echo "UserId: $userid"
echo "Account: $account"
echo "UserArn: $userarn"


echo -e "\n"

# ---------------------------------------------------------- IAM USER Section Start

echo -e "${BLUE}=== IAM USER & Policy Check ===${NC}"


# IAM Get-user
echo -e "Testing iam get-user"
output=$(aws iam get-user --profile $aws_profile 2>&1)
if   echo "$output" | grep -q "AccessDenied";
then echo -e "${RED}Can not perform iam:GetUser \n${NC}"
else echo -e "${GREEN}- iam:GetUser available \n${NC}"
fi


# Listing Inline Policies
echo -e "Testing iam list-user-policies"
output=$(aws iam list-user-policies --user-name $username --profile $aws_profile 2>&1)
if   echo "$output" | grep -q "AccessDenied";
then echo -e "- Can not perform iam:ListUserPolicies \n"
else 
	touch "$aws_profile"/user_inline_policies.txt | 
	echo "$output" > "$aws_profile"/user_inline_policies.txt  | 
	echo -e "\n\n Use the following commands to enumerate the policies:\n\n1:aws iam get-user-policy --profile "$aws_profile" --user-name "$username" --policy-name " >> "$aws_profile"/user_inline_policies.txt | 
	echo -e "${GREEN}- Results in "$aws_profile"/user_inline_policies.txt \n${NC}"
fi


# Listing Attached Policies
echo "Testing iam list-attached-user-policies"
output=$(aws iam list-attached-user-policies --user-name $username --profile $aws_profile 2>&1)
if   echo "$output" | grep -q "AccessDenied";
then echo "Can not perform iam:ListAttachedUserPolicies"
else 
	touch "$aws_profile"/user_attached_policies.txt | 
	echo "$output" > "$aws_profile"/user_attached_policies.txt  | 
	echo -e "\n\nUse the following commands to enumerate the policies: \n\n1: Get Available Versions:  
	\n	aws iam list-policy-versions --profile "$aws_profile" --policy-arn 
	\n\n2: Enumerate each version: 
	\n	aws iam get-policy-version --profile "$aws_profile" --policy-arn --version-id " >> "$aws_profile"/user_attached_policies.txt | 
	echo -e "${GREEN}- Results in "$aws_profile"/user_attached_policies.txt${NC}"
fi


# ---------------------------------------------------------- IAM USER Section End
echo -e "\n"
# ---------------------------------------------------------- IAM Group Section Start
echo -e "${BLUE}=== IAM GROUP & POLICY Check ===${NC}"
# Listing Groups for User
echo "Testing iam list-groups-for-user"
output=$(aws iam list-groups-for-user --user-name $username --profile $aws_profile 2>&1)
if   echo "$output" | grep -q "AccessDenied";
then echo -e "${RED}- Can not perform iam:ListGroupsForUser${NC}"
else
	touch "$aws_profile"/user_groups.txt |
	echo "$output" > "$aws_profile"/user_groups.txt |
	echo -e "${GREEN}- Results in "$aws_profile"/user_groups.txt${NC}"
fi
# ---------------------------------------------------------- IAM Group Section End
echo -e "\n"
# ---------------------------------------------------------- IAM ROLE Section Start
echo -e "${BLUE}=== IAM ROLE & POLICY Check ===${NC}"
# Listing Roles
echo "Testing aws iam list-roles"
output=$(aws iam list-roles --profile $aws_profile 2>&1)
if   echo "$output" | grep -q "AccessDenied";
then echo -e "${RED}- Can not perform iam:ListRoles${NC}"
else touch "$aws_profile"/list_roles.txt | echo "$output" > "$aws_profile"/list_roles.txt | echo -e "${GREEN}- Results in "$aws_profile"/list_roles.txt${NC}"
fi
# ---------------------------------------------------------- IAM ROLE Section End
echo -e "\n"
# ---------------------------------------------------------- BeanStalk Section Start

echo -e "${BLUE}=== Beanstalk Check ===${NC}"
echo "Testing aws elasticbeanstalk describe-environments"
output=$(aws elasticbeanstalk describe-environments --profile $aws_profile 2>&1)
if echo "$output" | grep -q "AccessDenied";
then echo "${RED}Can not enumerate beanstalk environments${NC}"
else 
	touch "$aws_profile"/elastic_beanstalk_environments.txt | 
	echo "$output" > "$aws_profile"/elastic_beanstalk_environments.txt | 
	echo -e "${GREEN}- Results in "$aws_profile"/elastic_beanstalk_environments.txt${NC}"
fi

# ---------------------------------------------------------- BeanStalk Section End
echo -e "\n"
# ---------------------------------------------------------- SNS Section Start
echo -e "${BLUE}=== SNS Check ===${NC}"
echo "Testing aws sns list-topics"
output=$(aws sns list-topics --profile $aws_profile 2>&1)
if echo "$output" | grep -q "AccessDenied";
then echo "${RED}Can not enumerate SNS Topics${NC}"
else 
	touch "$aws_profile"/sns_listing.txt | 
	echo "$output" > "$aws_profile"/sns_listing.txt | 
	echo -e "\n\nRun the following commands to enumerate topics further \n\n1: aws sns get-topic-attributes --topic-arn <arn> --profile "$aws_profile" \n\n2: aws sns list-subscriptions-by-topic --topic-arn <arn> --profile "$aws_profile"" >> "$aws_profile"/sns_listing.txt |
	echo -e "${GREEN}- Results in "$aws_profile"/sns_listing.txt${NC}"
fi
# ---------------------------------------------------------- SNS Section End
