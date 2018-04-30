# Standard libraries
require 'json'
require 'csv'

# OSA
require 'osa/version'
require 'osa/security_groups'
require 'osa/servers'
require 'osa/report'

# Gems
require 'openstack'
require 'terminal-table'
require 'axlsx'


module OSA
  String.class_eval { include Extensions::String }
end