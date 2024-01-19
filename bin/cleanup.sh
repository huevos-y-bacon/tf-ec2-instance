#!/usr/bin/env bash
# shellcheck disable=1091,2162

source colours 2>/dev/null

CWD=$(basename "$(pwd)")
if [ "$CWD" == "bin" ]; then
    echo "${RED}Error: Script cannot be executed directly from inside ${CWD}.${NORM}"
    exit 1
fi

confirm(){
  INPUT=$*
  do_confirm(){
    [[ -n $INPUT ]] && echo -e "${BOLD}${YELLOW}${INPUT}${RED}"
    read -p "Are you sure you want to proceed? (y/n) ${NORM}" choice
    case "$choice" in
      y|Y ) ;;
      * ) echo -e "Aborting\n" && exit;;
    esac
  };

  if [[ ! $FORCE ]]; then do_confirm; fi
  echo "${NORM}"
  unset INPUT
}

confirm "This will destroy the EC2 instance"

terraform destroy --auto-approve

confirm "This will destroy all generated config - only do this if the terraform resources have been destroyed!"

echo "${YELLOW}Deleting generated files:${BOLD} .terraform*, terraform.tfstate*, vpc_subnet.tf${NORM}"
rm -rf .terraform
rm -f .terraform.*
rm -f terraform.tfstate*
rm -f vpc_subnet.tf

if [[ -f terraform.tfvars ]]; then
  echo -e "\n${GREEN}Retained ${BOLD}terraform.tfvars${NORM}\n"
fi
