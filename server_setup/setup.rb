require 'rubygems'
require '../server'
require 'etc'

USER = 
begin
  IO.read(Dir[Dir.home + '/.thunderbird/**/prefs.js'].first).scan(/"NTDOMAIN\\\\.*"/).first.gsub(/(NTDOMAIN\\\\|")/, '')
rescue
  Etc.getlogin 
end

KEY_NAME = 'sealink'
server = Server.new(ENV['HOST'], 22, USER)

def ubu_do(server)
	server.user = "ubuntu"
	server.identity = Dir.home << '/' << KEY_NAME << '.pem'
end
def cap_do(server)
	server.user = "capistrano"
	server.identity = Dir.home << '/.ssh/id_rsa'
end

#ubu_do(server)
#server.recipe(:setup_apt_sources, :old_source => 'ap-southeast-1.ec2.archive.ubuntu.com/ubuntu/' , :source => 'ap-southeast-1.ec2.archive.ubuntu.com.s3.amazonaws.com')

#ubu_do(server)
#server.recipe(:setup_apt_sources, :old_source => 'au.archive.ubuntu.com', :source => 'mirror.internode.on.net/pub/ubuntu')
#server.recipe(:setup_user, :user => 'capistrano')
#server.download("https://secure.quicktravel.com.au/deployments/authorized_keys2.txt", '~/authorized_keys.defaults')
#server.recipe(:setup_authorized_key, :base => '/home/capistrano/.ssh')

#if false
cap_do(server)
server.scp("percona.preseed", '/home/capistrano/percona.preseed')
server.recipe(:setup_percona_server)
server.ssh("sudo apt-get update")
#server.recipe(:setup_quicktravel_app)
#server.recipe(:setup_quicktravel_app_manual_dependencies)
#server.recipe(:setup_quicktravel_ruby)

#server.scp("nginx.site.example.conf", '/home/capistrano/nginx.site.example.conf')
#server.scp("nginx.sites.defaults.conf", '/home/capistrano/nginx.sites.defaults.conf')
#server.recipe(:setup_nginx)
#end
