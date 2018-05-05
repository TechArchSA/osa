# frozen_string_literal: true
module OSA
  #
  #
  #
  class SecurityGroups

    # wrapper for a security group
    SecurityGroup = Struct.new(
                                :id,
                                :name,
                                :description,
                                :tenant_id,
                                :rules # @sec_grp_objs of this security group rules objects
    )
    # wrapper for a rule in a SecurityGroup object
    Rule          = Struct.new(
                                :id,
                                :ip_protocol,
                                :from_port, :to_port,
                                :ip_range,
                                :parent_group_id,
                                :parent_group_name,
                                :group
    )

    # @!attribute [r] parsed security groups
    # @return [Array <Hash>] @sec_grp_objs of SecurityGroup
    #
    #   [
    #     #<Struct:OSA::SecurityGroups::SecurityGroup:0x55edeb8f9f38
    #     description = "Default security group",
    #         id = "8f158e39-bf00-43c4-906f-65a3e3737d5a",
    #         name = "default",
    #         rules = [
    #             #<Struct:OSA::SecurityGroups::Rule:0x55edeb8f8070
    #             from_port = 0,
    #             group_name = nil,
    #             group_tenant_id = nil,
    #             id = "90baca7d-dad5-4761-92f9-2fa90f08fc17",
    #             ip_protocol = "any",
    #             ip_range = {},
    #             parent_group_id = "8f158e39-bf00-43c4-906f-65a3e3737d5a",
    #             rules = nil,
    #             to_port = 65535
    #         >,
    #         #<Struct:OSA::SecurityGroups::Rule:0x55edeb8f9830
    #         from_port = 0,
    #         group_name = nil,
    #         group_tenant_id = nil,
    #         id = "4371ea6d-8c5e-4685-b1fd-cd8a81d8994f",
    #         ip_protocol = "any",
    #         ip_range = {},
    #         parent_group_id = "8f158e39-bf00-43c4-906f-65a3e3737d5a",
    #         rules = nil,
    #         to_port = 65535
    #     >
    #     ],
    #         tenant_id = "3cb892c5109b41aea6c87eac113bdbed"
    #     >,
    #   ....
    #
    #   ]
    #
    attr_reader :sec_grp_objs
    attr_reader :security_groups
    attr_reader :list

    # Interface for the core parser (@see SecurityGroups#parser method)
    #
    # @return [SecurityGroups] object
    def self.parse(security_groups)
      new.parser(security_groups)
    end

    # The core parser, it expects a Hash comes from openstack.security_groups,
    #   parses the retrieved security_groups hash from openstack.security_groups then
    #   extracts the needed data and build a SecurityGroup object from this data.
    #   currently, the needed data is [SecurityGroup]:
    #   id, ip_protocol, from_port, to_port, ip_range, parent_group_id group_tenant_id, group_name
    #
    # @params security_groups [Hash]
    #   Hash comes from openstack.security_group
    #
    # @example
    #   openstack = OpenStack::Connection.main(connection)
    #   os_security_groups = openstack.security_groups
    #   security_groups = SecurityGroups.parse(os_security_groups)
    #
    # @return SecurityGroups object
    #
    def parser(security_groups)
      @security_groups = security_groups
      @sec_grp_objs    = objectize_security_groups(security_groups)
      # @list            = retrieve_remote_group # Fixme list and the method
      retrieve_remote_group # Fixme list and the method
      @list            = @sec_grp_objs # Fixme list and the method
      self
    end

    # searches for a security group by id
    #
    # @param type [Symbol]
    #   type id or name
    #   the id format expected to be as open stack id format. (eg. "3d453836-1a44-44dc-a709-ea607a4ac462")
    #
    # @return [SecurityGroup] object
    #
    def find_by(type, data)
      case type
      when :id   then @sec_grp_objs.select {|security_group| security_group.id == data}
      when :name then @sec_grp_objs.select {|security_group| security_group.name == data}
      else
        raise "[+] Unknown search type '#{type}'. Only :id, :name allowed" unless (type == :id || type == :name)
      end
    end

    # searches for a rule by id
    #
    # @param id [String]
    #   the id format expected to be as open stack id format. (eg. "3d453836-1a44-44dc-a709-ea607a4ac462")
    #
    # @return [Array<[SecurityGroup]>]
    #   Array of SecurityGroup objects that contains the given Rule's id
    #
    def find_rule(id)
      @sec_grp_objs.select { |security_group| security_group.rules.select{ |rule| rule.id == id }}
    end

    # Iterator for security groups can take a block
    #
    # @example
    #   security_groups.each_security_group
    #   security_groups.each_security_group(&:rules) {|rule| puts rule.name}
    #   security_groups.each_security_group(&:rules) == security_groups.each_rule #=> true
    #
    # @return [Array <SecurityGroup>] if no block given
    #
    def each_security_group(&block)
      @sec_grp_objs.map { |security_group| block_given? ? yield(security_group) : security_group }.flatten
    end

    # Iterator for rules can take a block
    #
    # @example
    #   security_groups.each_rule(&:parent_group_name)
    #   security_groups.each_rule {|rule| puts rule.name}
    #   security_groups.each_rule == security_groups.each_security_group(&:rules) #=> true
    #
    # @return [Array <Rule>] if no block given
    #
    def each_rule(&block)
      self.each_security_group(&:rules).map { |rule| block_given? ? yield(rule) : rule}.flatten
    end

    private
    # Takes a raw security_group from OpenStack#security_groups and parse it into objects of
    #   SecurityGroup objects for security group and Rule objects for rules
    #
    # @return [Array <SecurityGroup>]
    #
    def objectize_security_groups(security_groups)
      security_groups.keys.map do |sec_id|
        secgrp_raw     = security_groups[sec_id]
        rules_objects  = secgrp_raw[:rules].map { |rule| build_rule_object(rule, secgrp_raw) }
        build_security_group_object(secgrp_raw, rules_objects)
      end
    end

    # Build Rule object while parsing (@see parser)
    #
    # @return [Rule]
    #
    def build_rule_object(rule, security_group)
      Rule.new(
          rule[:id],                # rule's id
          rule[:ip_protocol],       # protocol
          rule[:from_port],         # source ports
          rule[:to_port],           # destination ports
          rule[:ip_range][:cidr],   # source ip_range
          rule[:parent_group_id],   # the original security group's id
          security_group[:name],    # the original security group's id
          rule[:group][:name]       # remote security group
      )
    end

    # Build SecurityGroup object while parsing (@see parser)
    #
    # @return [SecurityGroup]
    #
    def build_security_group_object(secgrp, rules)
      SecurityGroup.new(secgrp[:id], secgrp[:name], secgrp[:description], secgrp[:tenant_id], rules)
    end

    # retrieve all remote/parent security groups and add it to the group of each rule
    #
    # @return [SecurityGroups] object
    #
    def retrieve_remote_group
      self.each_security_group do |sg|
        sg.rules.map do |rule|
          next if rule.group.nil? || rule.group == rule.parent_group_name
          rule.group = self.find_by(:name, sg.name)
        end
      end
    end
  end
end