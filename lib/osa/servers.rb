# frozen_string_literal: true
module OSA
  #
  # Servers class has all Server data parsing and extraction related functionalities
  #
  class Servers
    Server = Struct.new(:id, :name, :status, :addresses, :security_groups, :tenant_id)
    Address = Struct.new(:public, :private)

    # @!attribute [r]
    #   servers sec_grp_objs of <Array [Server]> parsed servers
    #   servers_details @ec_grp_objs of servers details
    attr_reader :servers
    alias :list :servers

    # @!attribute [r]
    #   servers_details sec_grp_objs of servers details
    attr_reader :servers_details

    # Interface for the core parser (@see Servers#parser method)
    #
    # @return [Servers] object
    def self.parse(servers)
      new.parser(servers)
    end

    #
    # core parser, it expects Array of Hashes of server details from openstack.servers_detail,
    #   parses the retrieved array from openstack.servers_detail then extracts the needed data
    #   and build a Server object from this data.
    #   currently, the needed data is [Server]:
    #   id, name, status, addresses, security_groups, tenant_id
    #
    # @param servers [Array <Hash>]
    #
    # @example
    #   openstack = OpenStack::Connection.create(connection)
    #   servers_details = openstack.servers_detail
    #   servers = Servers.parse(server_details)
    #
    # @return [Server] object
    #
    def parser(servers)
      @servers =
          servers.map do |server|
            Server.new(
                server[:id], server[:name], server[:status],
                # @!method parse server's addresses
                parse_addresses(server[:addresses]),
                # @!method parse server's security_groups
                parse_security_groups(server[:security_groups]),
                server[:tenant_id]
            )
          end
      self
    end

    #
    # maps all details of openstack's security_groups with servers' security_groups to
    #   merge required details since servers' details have only security groups' names
    #
    # @param security_groups [SecurityGroups] object or [Array <SecurityGroup>]
    #   if SecurityGroups is given #neutralize_security_groups will get the SecurityGroups#@sec_grp_objs ([Array <SecurityGroup>])
    #   if SecurityGroups#@sec_grp_objs ([Array <SecurityGroup>]), #neutralize_security_groups returns it.
    #
    # @example
    #   openstack = OpenStack::Connection.create(connection)
    #   security_groups = SecurityGroups.parse(openstack.security_groups).security_groups
    #   servers = Servers.parse(openstack.servers_detail)
    #   servers.map_security_groups(security_groups)
    #
    # @return [Array <[Servers]>]
    #
    def map_security_groups(security_groups)
      security_groups = neutralize_security_groups(security_groups)
      @servers_details =
          @servers.each do |server|
            server[:security_groups] =
                security_groups.select do |security_group|
                  # We must match by name since the server's details includes security groups' names only
                  server.security_groups.include? security_group.name
                end
          end
    end
    alias :list_servers_details :servers_details

    # FIXME to find servers by security group id or name using mapped data
    def find_by()

    end


    private
    # parse server's addresses
    # @param addresses [Hash<Hash>, [Array]]
    # @return [Array]
    def parse_addresses(addresses)
      public  = addresses[:public].collect{|ip|  ip[:addr]}
      private = addresses[:private].collect{|ip| ip[:addr]}
      # {public: public, private: private}
      Address.new(public, private)
    end

    # parse server's security_groups
    # @param security_groups [Hash]
    # @return [Array]
    def parse_security_groups(security_groups)
      security_groups.map(&:values).flatten
    end

    #
    # neutralize and handle the given value to be <Array [SecurityGroup]>
    #   if SecurityGroups is given, #neutralize_security_groups will get the SecurityGroups#sec_grp_objs ([Array <SecurityGroup>])
    #   if SecurityGroups#sec_grp_objs ([Array <SecurityGroup>]), #neutralize_security_groups returns it.
    #
    # @param security_groups [SecurityGroups] or [Array <SecurityGroup>].
    #   Unexpected type exception kicks-in if unexpected type is given
    #
    # @return [Array <SecurityGroup>]
    #
    def neutralize_security_groups(security_groups)
      return security_groups.sec_grp_objs if security_groups.kind_of? OSA::SecurityGroups
      return security_groups              if security_groups.kind_of? Array
      raise
    rescue Exception => e
      puts "[!] Unexpected type [#{security_groups.class}]: expecting SecurityGroups or Array of SecurityGroup"
      puts e.backtrace
    end
  end
end
