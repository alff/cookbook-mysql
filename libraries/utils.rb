#!/usr/bin/env ruby

module MG
  def query_var(server,attrs={})
    attrib = attrs["attr"]
    a_key = attrs["key"]
    a_var = attrs["var"]
    case a_var
    when nil
      server.attribute?(attrib)&&server[attrib].key?(a_key)&&server[attrib][a_key]
    else
      server.attribute?(attrib)&&server[attrib].key?(a_key)&&server[attrib][a_key]==a_var
    end
  end
  def check_state_attr(server,attrs={})
    a_time = attrs["timeout"]
    sttime = attrs["sttime"]
    q = query_var(server,attrs)
    until q do
      if (Time.now.to_f-sttime)>=a_time
        Chef::Application.fatal! "Timeout exceeded while node #{server.name} syncing.."
      else
        Chef::Log.info "Waiting while node #{server.name} syncing.."
        sleep 10
        server = search(:node, "name:#{server.name} AND chef_environment:#{node.chef_environment}")[0]
        q = query_var(server,attrs)
      end
    end
    true
  end
end

class Chef::Recipe
  include MG
end
class Chef::Resource::Template
  include MG
end
class Chef::Resource::RubyBlock
  include MG
end
