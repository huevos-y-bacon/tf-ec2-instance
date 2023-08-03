# Quick Terraform EC2 Instance

- Create an EC2 instance (Latest Amazon Linux 2) in AWS in a chosen VPC and subnet (**run bash script to populate locals!**)
- Create a security group, role, instance profile, etc.

***NOTE*** - STATE IS STORED LOCALLY

##  Steps

1. Prepare the necesary subnet locals using the script
    - `get_vpc_and_subnet.sh`
      - *NOTE*: this script is used to generate the `vpc_subnet.tf` file
    - Filter subnets by name with the first argument
      - e.g. `./get_vpc_and_subnet.sh private`
2. Run `tfinit`, `tfplan`, `tfapply`, etc as usual 
