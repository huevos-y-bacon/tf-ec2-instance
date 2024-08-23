#!/bin/bash

PACKAGE_LIST=(
  git
  python3
  python3-pip
  jq
  wget
  unzip
)

if [[ -n $(command -v apt) ]]; then
  sudo apt update -y
  for package in "${PACKAGE_LIST[@]}"; do
    echo -e "\n#### INSTALLING ${package} ####"
    sudo apt install -y "${package}"
  done
elif [[ -n $(command -v yum) ]]; then
  sudo yum update -y
  for package in "${PACKAGE_LIST[@]}"; do
    echo -e "\n#### INSTALLING ${package} ####"
    sudo yum install -y "${package}"
  done
fi
