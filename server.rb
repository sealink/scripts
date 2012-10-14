require 'yaml' # For server parsing
require 'erubis' # For recipe

class Server
  
  attr_accessor :host, :short_host, :port, :user, :identity

  @@servers = []  
  
  def initialize(host, port, user)
    @host = host
    @short_host = short_host
    @port = port if port && port != ''
    @user = user
  end

  def short_host
    if is_ip? 
      host
    elsif ['com', 'net', 'org'].include?(host.split('.').last)
      host.split('.').first
    elsif ['com', 'net', 'org'].include?(host.split('.')[0..-2].last)
      host.split('.')[0..-4].join('.')
    else
      host.split('.')[0..-3].join('.')
    end
  end

  def is_ip?
    !@host.match(/\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/).nil?
  end

  def ssh(command_string)
    command_string.split("\n").each do |command|
      next if command == '' || command[0] == '#'
      res = command(ssh_base + " '#{command}'")
      puts res
    end
  end

  def ssh_as_sudo(command_string, password)
    command("sshpass -p#{password} #{ssh_base} -t \"sudo #{command_string}\"")
  end

  def ssh_base
    [
      "ssh",
      ("-i #{identity}" if identity),
      ("-l #{user}" if user),
      port_argument,
      host
    ].compact.join(" ")
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

  def download(url, destination)
    ssh("wget --output-document #{destination} #{url}")
  end

  def port_argument
    @port_argument ||= (@port ? "-p #{@port}" : "")
  end

  def scp_port_argument
    @scp_port_argument ||= (@port ? "-P #{@port}" : "")
  end

  def self.servers
   @@servers
  end

  def self.load
    server_hashes = YAML::load(File.read('servers.yml'))
    @@servers = server_hashes.map do |h|
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

