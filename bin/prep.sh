#!/usr/bin/env bash
# shellcheck disable=2016,2155,1091,2312,2181

# THIS SCRIPT IS USED TO GENERATE THE vpc_subnet.tf FILE
# Filter subnets by name with the first argument
#   - e.g. bin/prep.sh private

# Check for jq, aws
command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required but it's not installed.  Aborting."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo >&2 "aws is required but it's not installed.  Aborting."; exit 1; }

RED=$(tput setaf 1); NORM=$(tput sgr0)
GREEN=$(tput setaf 2); BOLD=$(tput bold)
CWD=$(basename "$(pwd)")

if [[ "${CWD}" == "bin" ]]; then
    echo "${RED}Error: Script cannot be executed directly from inside ${CWD}.${NORM}"
    exit 1
fi

# source .env if exist
if [[ -f .env ]]; then
  source .env
fi

# set profile=--profile $profile if $profile is set
if [[ -n $aws_profile ]]; then
  profile="--profile $aws_profile"
  echo "${RED}Using AWS profile: ${BOLD}${aws_profile}"
  echo "Update the aws provider in providers.tf to change the profile used by terraform${NORM}"
fi

extract_vpcs(){
  aws ec2 describe-vpcs ${profile} \
    --query 'Vpcs[*].[
        Tags[?Key==`Name`].Value | [0],
        VpcId,
        CidrBlock
      ]' \
    --output json | jq -r '.[] | @csv' | sed 's/[[:space:]]/-/g'
}

select_vpc() {
  echo "Select a VPC:"
  select vpc in ${vpcs};
  do
    echo -e "\nYou selected ${vpc} (${REPLY})\n"
    export VPC_ID=$(echo "${vpc}" | cut -d ',' -f 2 | sed 's/"//g')
    export VPC_CIDR=$(echo "${vpc}" | cut -d ',' -f 3 | sed 's/"//g')
    return
  done
}

extract_subnets(){
  aws ec2 describe-subnets ${profile} \
    --filters "Name=vpc-id,Values=${VPC_ID}" \
    --query 'Subnets[*].[
        Tags[?Key==`Name`].Value | [0],
        SubnetId,
        CidrBlock
      ]' \
    --output json | jq -r '.[] | @csv' | sed 's/[[:space:]]/-/g'
}

select_subnet(){
  echo "Select a subnet:"
  select subnet in ${subnets};
  do
    echo -e "\nYou selected ${subnet} (${REPLY})\n"
    export SUBNET_ID=$(echo "${subnet}" | cut -d ',' -f 2 | sed 's/"//g')
    export SUBNET_CIDR=$(echo "${subnet}" | cut -d ',' -f 3 | sed 's/"//g')
    return
  done
}

scheduler_prompt(){
  echo "Do you want to schedule the instance to stop at 6pm daily? (you can update this in terraform.tfvars later)"
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) SCHED="# sched_cron     = \"cron(0 18 * * ? *)\" # Instance shutdown scheduler"; echo "Scheduler enabled"; cp scheduler.tf_ scheduler.tf; return;;
      No ) return 0;;
    esac
  done
}

vpcs="$(extract_vpcs | sort)"
if [[ -z $vpcs ]]; then
  echo "${RED}No VPCs found. Exiting.${NORM}"
  exit 1
fi
select_vpc || exit 1

subnets="$(extract_subnets | sed 's/[[:space:]]//g' | sort)"
if [[ -z $subnets ]]; then
  echo "${RED}No subnets found. Exiting.${NORM}"
  exit 1
fi

# Filter subnets by name
if [[ -n $1 ]]; then
  filter=$1
  echo -e "Filtering subnets by string: ${RED}${filter}${NORM}\n"
  subnets="$(echo "${subnets}" | grep -i "${filter}")"
fi

select_subnet || exit 1
TODAY=$(date +%Y%m%d)
USER=$(whoami)

scheduler_prompt || exit 1

echo "name_prefix = \"${USER}-${TODAY}\"
vpc_id      = \"${VPC_ID}\" 
vpc_cidr    = \"${VPC_CIDR}\"
subnet_id   = \"${SUBNET_ID}\"
subnet_cidr = \"${SUBNET_CIDR}\"

# Other variable overrides
# ssh_from_my_ip = true # default is false
# key_name = \"my-key\" # default is empty
# attach_eip = true # default is false
# linux_version  = \"ubuntu22\" # Options: al2023 (default), al2 (not recommended) and ubuntu22
# size           = \"large\" # Options: nano, micro (default), small, medium, large, etc
# graviton       = false # default is true
${SCHED}
" > terraform.tfvars

echo -e "\n${BOLD}Generated terraform.tfvars:${NORM}${GREEN}\n"
cat terraform.tfvars
tput sgr0
