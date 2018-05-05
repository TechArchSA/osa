# frozen_string_literal: true
require 'osa/rules/exposed_admin_ports'

module OSA
  module Audit
    # caller for audit rules
    #
    # @param [security_groups_map]
    #
    # @param rule_name [String]
    #
    # @param options [Hash]
    #   the options is data store for all rules_options
    #   each rule will extract the data it need from the hash
    #   so the options belongs to everyone
    #
    # @return [OSA::Audit::Rule]
    #
    def self.rule(security_group_map, rule_name, options = {})
      case rule_name
      when "all"
        Rule::ExposedAdminPorts.run(security_group_map, options)
      when "exposed_admin_ports"
        Rule::ExposedAdminPorts.run(security_group_map, options)
      when "overlap_rules"
        # TODO
      when "insecure_protocol"
        # TODO
      else
        Rule::ExposedAdminPorts.run(security_group_map, options)
      end
    end
  end
end
