#
# Cookbook Name:: aws_ec2
# Recipe:: default
#
# Copyright 2013, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

#
# Amazon Web Services
# http://rubygems.org/gems/aws-sdk
#
include_recipe "xml"
include_recipe "build-essential"

%w{ libcurl4-gnutls-dev make }.each do |pkg|
  package pkg do
    action :install
  end
end

chef_gem "aws-sdk" do
  action :install
end

require 'aws-sdk'

AWS.config(
           :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
           :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"],
           :region => ENV["AWS_DEFAULT_REGION"],
           )


#
# AWS cli tools
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
  else
    export AWS_DEFAULT_REGION="ap-northeast-1"
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
