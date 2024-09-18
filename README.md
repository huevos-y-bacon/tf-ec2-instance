# Quick Terraform EC2 Instance

- Create an EC2 instance (Latest Amazon Linux 2023 (default), Amazon Linux 2 (not recommended) or Ubuntu 22.04, and graviton by default) in AWS in a chosen VPC and subnet (**run bash script to populate locals!**).
- This creates a t3 or t4g instance. If you want to use something else, specify `local.instance_type`.

- Create a security group, role, instance profile, etc.

- Example `terraform.tfvars` if you need to override some defaults:

  ```py
  size    = "small"     # defualt micro
  purpose = "STEAMPIPE" # default null, generate long resource name
  # graviton = false    # default true
  ```

- ***NOTE*** - STATE IS STORED LOCALLY

## Steps

1. Prepare the necesary subnet locals using the script `bin/prep.sh`
    - This script is used to generate the `vpc_subnet.tf` file
    - You can filter subnets by name with the first argument
      - e.g. `bin/prep.sh private`
2. Create `.env` in `./` if you need to specify an AWS CLI Profile to use (add `aws_profile=profile_name`)
3. Run `tfinit`
4. Run `tfplan`, `tfapply`, etc as usual

## Cleanup

1. Run `bin/cleanup.sh` to initiate cleanup.
2. It will first destroy the TF resources (after confirmation), after which it will delete local generated config and all `.terraform*` files (after another confirmation)
3. ***NOTE:** this will not remove `terraform.tfvars`*

---

## Notes

### Public IP Addresses

If you deploy into a public subnet, your instance would be assigned a public IP address only if your VPC is configured to automatically assign public IPs. It is best practice to disable this. If you want to deploy into a public subnet that does not auto-assign public IPs, you need to set the `attach_eip` variable to `true`.

### AMIs

The instance resource is configured to ignore changes to the value of `data.aws_ami.al2.id` to avoid recreating the instance, otherwise it would recreate the instance every time a new version of the AMI is released.
