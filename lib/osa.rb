# Standard libraries
require 'json'
require 'yaml'

# OSA
require 'osa/version'
require 'osa/security_groups'
require 'osa/servers'
require 'osa/report'
require 'osa/utils'
require 'osa/helpers'
require 'osa/audit'

# Gems
require 'openstack'
require 'terminal-table'
require 'axlsx'


module OSA

  String.class_eval { include OSA::Helpers::Extensions::Core::String }

end