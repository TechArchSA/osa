# Standard libraries
require 'json'
require 'csv'

# OSA
require 'osa/version'
require 'osa/security_groups'
require 'osa/servers'
require 'osa/report'
require 'osa/utils'
require 'osa/extensions'

# Gems
require 'openstack'
require 'terminal-table'
require 'axlsx'


module OSA

  String.class_eval { include OSA::Extensions::CoreExtentions::String }

end