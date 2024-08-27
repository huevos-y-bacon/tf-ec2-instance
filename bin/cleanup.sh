#!/usr/bin/env bash
# shellcheck disable=1091,2162,2312

source colours 2>/dev/null

CWD=$(basename "$(pwd)")
if [[ "${CWD}" == "bin" ]]; then
    echo "${RED}Error: Script cannot be executed directly from inside ${CWD}.${NORM}"
    exit 1
fi

confirm(){
  INPUT=$*
  do_confirm(){
    [[ -n ${INPUT} ]] && echo -e "${BOLD}${YELLOW}${INPUT}${RED}"
    read -p "Are you sure you want to proceed? (y/n) ${NORM}" choice
    case "${choice}" in
      y|Y ) ;;
      * ) echo -e "Aborting\n" && exit;;
    esac
  };

  if [[ -z ${FORCE} ]]; then do_confirm; fi
  echo "${NORM}"
  unset INPUT
}

prompt_retain_tfvars(){
  echo
  read -p "Do you want to retain terraform.tfvars? (y/n) " choice
  case "${choice}" in
    n|N ) echo -e "${RED}Deleting ${BOLD}terraform.tfvars*${NORM}"; rm -f terraform.tfvars*;;
    * ) return;;
  esac
}

confirm "This will destroy the EC2 instance"

terraform destroy --auto-approve

confirm "This will destroy all generated config - only do this if the terraform resources have been destroyed!"

echo "${YELLOW}Deleting generated files${NORM}"
LIST=(
  .terraform
  .terraform.*
  terraform.tfstate*
  # terraform.tfvars* # prompt to retain
  vpc_subnet.tf
  scheduler.tf
  lambda_function*
)

for item in "${LIST[@]}"; do
  if [[ -e ${item} ]]; then
    echo -e "${RED}Deleting ${BOLD}${item}${NORM}"
    rm -rf ${item}
  fi
done

if [[ -z ${FORCE} ]]; then prompt_retain_tfvars; else rm -f terraform.tfvars*; fi

if [[ -f terraform.tfvars ]]; then
  echo -e "\n${GREEN}Retained ${BOLD}terraform.tfvars${NORM}\n"
fi
