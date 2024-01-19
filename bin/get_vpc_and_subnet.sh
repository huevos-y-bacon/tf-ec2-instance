#!/usr/bin/env bash
# shellcheck disable=2016,2155,1091

# THIS SCRIPT IS USED TO GENERATE THE vpc_subnet.tf FILE
# Filter subnets by name with the first argument
#   - e.g. bin/get_vpc_and_subnet.sh private

source colours 2>/dev/null

CWD=$(basename "$(pwd)")
if [ "$CWD" == "bin" ]; then
    echo "${RED}Error: Script cannot be executed directly from inside ${CWD}.${NORM}"
    exit 1
fi

extract_vpcs(){
  aws ec2 describe-vpcs \
    --query 'Vpcs[*].[
        Tags[?Key==`Name`].Value | [0],
        VpcId,
        CidrBlock
      ]' \
    --output json | jq -r '.[] | @csv'
}

select_vpc() {
  echo "Select a VPC:"
  select vpc in ${vpcs}; # 
  do
    echo "You selected ${vpc} (${REPLY})"
    export VPC_NAME=$(echo "${vpc}" | cut -d ',' -f 1 | sed 's/"//g')
    export VPC_ID=$(echo "${vpc}" | cut -d ',' -f 2 | sed 's/"//g')
    export VPC_CIDR=$(echo "${vpc}" | cut -d ',' -f 3 | sed 's/"//g')
    return
  done
}

extract_subnets(){
  aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=${VPC_ID}" \
    --query 'Subnets[*].[
        Tags[?Key==`Name`].Value | [0],
        SubnetId,
        CidrBlock
      ]' \
    --output json | jq -r '.[] | @csv'
}

select_subnet(){
  echo "Select a subnet:"
  select subnet in ${subnets};
  do
    echo "You selected ${subnet} (${REPLY})"
    export SUBNET_NAME=$(echo "${subnet}" | cut -d ',' -f 1 | sed 's/"//g')
    export SUBNET_ID=$(echo "${subnet}" | cut -d ',' -f 2 | sed 's/"//g')
    export SUBNET_CIDR=$(echo "${subnet}" | cut -d ',' -f 3 | sed 's/"//g')
    return
  done
}

vpcs="$(extract_vpcs | sort)"
select_vpc || exit 1

subnets="$(extract_subnets | sed 's/[[:space:]]//g' | sort)"

# filter subnets by name
if [[ -n $1 ]]; then
  filter=$1
  echo "Filtering subnets by string: ${filter}"
  subnets="$(echo "${subnets}" | grep -i "${filter}")"
fi

select_subnet || exit 1
TODAY=$(date +%Y%m%d)
USER=$(whoami)

echo "locals {
  name_prefix = \"${USER}-${TODAY}\"

  vpc_id      = \"${VPC_ID}\" 
  vpc_name    = \"${VPC_NAME}\" 
  vpc_cidr    = \"${VPC_CIDR}\"

  subnet_id   = \"${SUBNET_ID}\"
  subnet_name = \"${SUBNET_NAME}\"
  subnet_cidr = \"${SUBNET_CIDR}\"
}" > vpc_subnet.tf

echo "Generated vpc_subnet.tf :"
cat vpc_subnet.tf
