#!/usr/bin/env bash
# shellcheck disable=all
exit # don't run this, cat it instead

# git clone https://gist.github.com/38b154892c42ce7dde2f42c1eaf65706.git steampipe_commands

# INSTALL STEAMPIPE AND PLUGINS, configure for eu-west-1
sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
steampipe plugin install steampipe
steampipe plugin install aws
echo "connection \"aws\" {
  plugin = \"aws\"
  regions = [\"eu-west-1\"]
}" > ~/.steampipe/config/aws.spc

# INSTALL ALL MODS IN ONE FOLDER
cd
mkdir -p ~/aws_mods; cd ~/aws_mods
steampipe mod install github.com/turbot/steampipe-mod-aws-compliance
steampipe mod install github.com/turbot/steampipe-mod-aws-insights
steampipe mod install github.com/turbot/steampipe-mod-aws-perimeter
steampipe mod install github.com/turbot/steampipe-mod-aws-tags
steampipe mod install github.com/turbot/steampipe-mod-aws-thrifty
steampipe mod install github.com/turbot/steampipe-mod-aws-top-10
steampipe mod install github.com/turbot/steampipe-mod-aws-well-architected
cd

# INSTALL MODS - Separate folders
cd
mkdir -p ~/compliance; cd ~/compliance; steampipe mod install github.com/turbot/steampipe-mod-aws-compliance; cd
mkdir -p ~/insights; cd ~/insights; steampipe mod install github.com/turbot/steampipe-mod-aws-insights; cd
mkdir -p ~/perimeter; cd ~/perimeter; steampipe mod install github.com/turbot/steampipe-mod-aws-perimeter; cd
mkdir -p ~/tags; cd ~/tags; steampipe mod install github.com/turbot/steampipe-mod-aws-tags; cd
mkdir -p ~/thrifty; cd ~/thrifty; steampipe mod install github.com/turbot/steampipe-mod-aws-thrifty; cd
mkdir -p ~/top-10; cd ~/top-10; steampipe mod install github.com/turbot/steampipe-mod-aws-top-10; cd
mkdir -p ~/well-architected; cd ~/well-architected; steampipe mod install github.com/turbot/steampipe-mod-aws-well-architected; cd

# DASHBOARDS
cd
cd ~/aws_mods; steampipe dashboard & # run dashboard in background
cd ~/compliance; steampipe dashboard & # run dashboard in background
cd ~/insights; steampipe dashboard & # run dashboard in background
cd ~/perimeter; steampipe dashboard & # run dashboard in background
cd ~/tags; steampipe dashboard & # run dashboard in background
cd ~/thrifty; steampipe dashboard & # run dashboard in background
cd ~/top-10; steampipe dashboard & # run dashboard in background
cd ~/well-architected; steampipe dashboard & # run dashboard in background

cd
