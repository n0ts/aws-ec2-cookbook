name             'aws_ec2'
maintainer       'Naoya Nakazawa'
maintainer_email 'me@n0ts.org'
license          'All rights reserved'
description      'Installs/Configures aws_ec2'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{ apt python }.each do |depend|
  depends depend
end
