#
# Cookbook Name:: aws_ec2
# Attributes:: default
#
# Copyright 2013, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

# Credentials for cli
# User Name,Access Key Id,Secret Access Key
default[:aws_ec2][:awscli_credentials_csv] = ""

default[:aws_ec2][:emrcli] = {
  :data_bag_load_secret_path => "",
  :data_bag_load_path => "",
  :data_bag_path => "",
  :data_bag_name => "",
  :keypair_name => "",
  :key_pair_file => "",
  :log_uri => "",
  :regiion => "",
  :user => "root",
}
