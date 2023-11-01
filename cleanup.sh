#!/usr/bin/env bash
# shellcheck disable=1091,2162

source colours 2>/dev/null

confirm(){
  INPUT=$*
  confirm(){
    [[ -n $INPUT ]] && echo -e "${YELLOW}${INPUT}${RED}"
    read -p "Are you sure you want to proceed? (y/n) ${NORM}" choice
    case "$choice" in
      y|Y ) ;;
      * ) echo -e "Aborting\n" && exit;;
    esac
  };

  if [[ ! $FORCE ]]; then confirm; fi
  echo "${NORM}"
}

confirm "This will destroy the EC2 instance"

terraform destroy --auto-approve

confirm "This will destroy all generated config - only do this if the terraform resources have been destroyed!"

echo "${YELLOW}Deleting generated files:${BLUE} .terraform* terraform.* vpc_subnet.tf${NORM}"
rm -rf .terraform
rm -f .terraform.*
rm -f terraform.*
rm -f vpc_subnet.tf
