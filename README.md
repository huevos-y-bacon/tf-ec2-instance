# Quick Terraform EC2 Instance

- Create an EC2 instance (Latest Amazon Linux 2, graviton by default) in AWS in a chosen VPC and subnet (**run bash script to populate locals!**).
- This creates a t3 or t4g instance. If you want to use something else, update `local.instance_type`.

- Create a security group, role, instance profile, etc.

- Example `terraform.tfvars` if you need to override some defaults:
  ```py
  size    = "small"     # defualt micro
  purpose = "STEAMPIPE" # default null, generate long resource name
  # graviton = false    # default true
  ```

- ***NOTE*** - STATE IS STORED LOCALLY

##  Steps

1. Prepare the necesary subnet locals using the script `bin/get_vpc_and_subnet.sh`
    - This script is used to generate the `vpc_subnet.tf` file
    - You can filter subnets by name with the first argument
      - e.g. `bin/get_vpc_and_subnet.sh private`
2. Run `tfinit`
3. Run `tfplan`, `tfapply`, etc as usual 

## Cleanup

1. Run `bin/cleanup.sh` to initiate cleanup.
2. It will first destroy the TF resources (after confirmation), after which it will delete local generated config and all `.terraform*` files (after another confirmation)
3. ***NOTE:** this will not remove `terraform.tfvars`*
