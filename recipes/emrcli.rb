#
# Cookbook Name:: aws_ec2
# Recipe:: emrcli
#
# Copyright 2013, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

emr_cli_home = "/usr/local/etc/elastic-mapreduce-cli"

# emrcli require for ruby 1.8.7
%w{ ruby-full unzip }.each do |pkg|
 package pkg
end

remote_file "/usr/local/etc/elastic-mapreduce-ruby.zip" do
  source "http://elasticmapreduce.s3.amazonaws.com/elastic-mapreduce-ruby.zip"
  owner "root"
  group "root"
  mode 0644
  action :create
end


bash "install-emr-cli" do
  code <<-EOH
  unzip /usr/local/etc/elastic-mapreduce-ruby.zip -d #{emr_cli_home}
EOH
  user "root"
  action :run
  not_if { ::FileTest.directory?(emr_cli_home) }
end

common_profile "emr-cli" do
  content <<-EOH
export PATH="#{emr_cli_home}:$PATH"
EOH
end


secret = Chef::EncryptedDataBagItem.load_secret(node[:aws_ec2][:emrcli][:data_bag_load_secret_path])
data_bag = Chef::EncryptedDataBagItem.load(node[:aws_ec2][:emrcli][:data_bag_load_path],
                                           node[:aws_ec2][:emrcli][:data_bag_name],
                                           secret)
file "#{emr_cli_home}/credentials.json" do
  content <<-EOH
{
  "access_id": "#{data_bag["access_key_id"]}",
  "private_key": "#{data_bag["secret_access_key"]}",
  "keypair": "#{node[:aws_ec2][:emrcli][:keypair]}",
  "key-pair-file": "#{node[:aws_ec2][:emrcli][:key_pair_file]}",
  "log_uri": "#{node[:aws_ec2][:emrcli][:log_uri]}",
  "region": "#{node[:aws_ec2][:emrcli][:region]}"
}
EOH
  user node[:aws_ec2][:emrcli][:user]
  group node[:aws_ec2][:emrcli][:user]
  mode 0600
  action :create
end
