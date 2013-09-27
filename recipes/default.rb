#
# Cookbook Name:: aws_ec2
# Recipe:: default
#
# Copyright 2013, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

#
# AWS tools
#
case node[:platform]
when 'ubuntu'
  apt_repository "aws" do
    uri "http://ap-northeast-1.ec2.archive.ubuntu.com/ubuntu/"
    distribution "saucy"
    components [ "multiverse" ]
    deb_src false
    action :add
  end

  package "ec2-api-tools" do
    action [:install, :upgrade]
  end
end

include_recipe "python"
python_pip "awscli"

common_profile "awscli" do
  content <<-EOH
if [ -x "`which aws 2> /dev/null`" ]; then
  AZ=`curl --connect-timeout 3 -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
  if [ -n "$AZ" ]; then
    export AWS_DEFAULT_REGION=`echo $AZ | cut -c 1-$((${#AZ} - 1))`
  fi
  complete -C aws_completer aws
fi
EOH
end


#
# Set hostname script
#
template "/usr/local/etc/ec2_const.sh" do
  source "ec2_const.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
end

template "/usr/local/bin/ec2_get_data.sh" do
  source "ec2_get_data.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
end

template "/usr/local/bin/ec2_set_hostname.sh" do
  source "ec2_set_hostname.sh.erb"
  owner "root"
  group "root"
  mode 0755
  action :create
  notifies :run, "execute[exec-ec2_set_hostname]"
end

execute "exec-ec2_set_hostname" do
  command "/usr/local/bin/ec2_set_hostname.sh"
  action :nothing
end


#
# Override node ostname and fqdn
#
node.override[:hostname] = `hostname`
node.override[:fqdn] = `hostname -a`
