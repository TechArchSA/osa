# OpenStack Security Auditor (OSA)

    OSA is OpenStack Security Auditor tool and library

If you are working on auditing and reviewing OpenStack Security Group rules, you'll directly recognize how tedious this task is. There's no direct way to list all security groups' rules related to each server. OpenStack has great API but it's abstract so you can merely list server details which contain "security group name" only, so you have to retrieve all security groups, inspect its rules to know the server's rules. This task is trivial if you have on or two servers and security group, but not in bigger environments.

## Features
- Easy and intuitive API 
- Support OpenStack APIv2 and APIv3
- Parsing Servers' details and Security Groups
- Resolve all referencing data into rich objects
- Mapping Servers with Security Groups
- Generate Terminal and Sheet yet neat reports 

## Installation

    $ gem install ossa

## Usage

```ruby
connection = {
    auth_url:            'https://api-example.com/identity/v3',
    auth_method:         'password',
    user_domain:         'datacenter1',
    username:            'YOURUSER',
    api_key:             'YOURPASSWORD',
    project_domain_name: 'datacenter1',
    project_name:        'OUR_CLOUD_PROJECT',
    service_type:        'compute',
    # is_debug: true
}
openstack = OpenStack::Connection.create(connection)
security_groups = SecurityGroups.parse(openstack.security_group)
pp security_groups.list
servers = Servers.parse(openstack.servers_detail)
pp servers.list
pp servers.list_details
```


## Contributing

1. Fork it ( https://github.com/TechArchSA/osa/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
