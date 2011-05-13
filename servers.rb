require 'yaml'

class Server
	attr_accessor :host, :short_host, :port, :user
	def initialize(host, port, user)
    @host = host
		@short_host = short_host
		@port = port if port && port != ''
		@user = user
	end

  def short_host
		Server.is_ip?(host) ? host : host.split('.').first
	end

	def self.is_ip?(host)
		host.gsub('.', '').chars.all?{|char| begin; Integer(char); rescue; false; end }
	end

	def run(command_string)
	  command(ssh_base + "\"#{command_string}\"")
	end

	def ssh_base
		"ssh -l #{user} #{port_argument} #{host}"
	end

	def port_argument
		@port_argument ||= (@port ? "-p #{@port}" : "")
	end
end

def load_servers
	server_hashes = YAML::load(File.read('servers.yml'))
	servers = server_hashes.map do |h|
		user_host, port = h.split(':')
		user, host = user_host.split('@')
		Server.new(host, port, user)
	end
end
