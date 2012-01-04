require 'yaml' # For server parsing
require 'erubis' # For recipe

class Server
  attr_accessor :host, :short_host, :port, :user
  def initialize(host, port, user)
    @host = host
    @short_host = short_host
    @port = port if port && port != ''
    @user = user
  end

  def short_host
    is_ip? ? host : host.split('.').first
  end

  def is_ip?
    !@host.match(/^[0-9\.]*$/).nil?
  end

  def ssh(command_string)
    command_string.split("\n").each do |command|
      next if command == '' || command[0] == '#'
      res = command(ssh_base + " '#{command}'")
      if server.respond_to?(:provider)
        res.each do |resu|
          resu.status.zero? or raise Exception, "Error exit was not 0 during command #{command} - #{resu.stderr} -- #{resu.stdout}"
        end
      else
        puts res
      end
    end
  end

  def ssh_as_sudo(command_string, password)
    command("sshpass -p#{password} #{ssh_base} -t \"sudo #{command_string}\"")
  end

  def ssh_base
    "ssh -l #{user} #{port_argument} #{host}"
  end

  def recipe(name, hash = {})
    text = File.read("recipes/#{name}")
    context = Erubis::Context.new(hash)
    commands = Erubis::Eruby.new(text).evaluate(context)
    ssh(commands)
  end

  def scp_download(remote, local)
    local ||= remote.split('/').last
    command("scp #{scp_port_argument} #{user}@#{host}:#{remote} #{local}")
  end

  def scp(local, remote)
    remote ||= local.split('/').last
    command("scp #{scp_port_argument} #{local} #{user}@#{host}:#{remote}")
  end

  def port_argument
    @port_argument ||= (@port ? "-p #{@port}" : "")
  end

  def scp_port_argument
    @scp_port_argument ||= (@port ? "-P #{@port}" : "")
  end

  def self.load
    server_hashes = YAML::load(File.read('servers.yml'))
    servers = server_hashes.map do |h|
      user_host, port = h.split(':')
      user, host = user_host.split('@')
      Server.new(host, port, user)
    end
  end
end

def command(string)
  puts "$ #{string}"
  res = `#{string}`
  puts ">> " + res
end

