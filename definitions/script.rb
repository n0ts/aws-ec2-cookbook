#
# Cookbook Name:: aws_ec2
# Definition:: script
#
# Copyright 2013, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

define :aws_ec2_script_mkfs_ebs, :device => "/dev/xvdf" do
  file "/usr/local/bin/aws_ec2_mkfs_ebs.sh" do
    content <<-EOH
# Generated by Chef for <%= @node[:fqdn] %>.
# Local modifications will be overwritten.

mkfs -t #{params[:name]} #{params[:device]}
echo -e "#{params[:device]}\t/data\t#{params[:name]}\tdefaults,noatime\t0\t0" >> /etc/fstab
mount -a
EOH
    owner "root"
    group "root"
    mode 0700
    action :create
  end
end
