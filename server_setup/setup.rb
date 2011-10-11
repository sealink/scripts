require 'rubygems'
require '../server'

server = Server.new(ENV['HOST'], 22, 'michael.noack')

def ubu_do(server)
	server.username = "ubuntu"
	server.private_key = File.read("/home/michael/michael.pem")
end
def cap_do(server)
	server.username = "capistrano"
	server.private_key = File.read("/home/michael/.ssh/id_rsa")
end

server.recipie(:setup_apt_sources, :source => 'mirror.internode.on.net/pub/ubuntu')
server.recipie(:setup_user, :user => 'capistrano')
server.scp("authorized_keys.defaults", '~/authorized_keys.defaults')
server.recipie(:setup_authorized_key, :base => '/home/capistrano/.ssh')

server.user = 'capistrano'
server.scp("percona.preseed", '/home/capistrano/percona.preseed')
server.recipie(:setup_percona_server)
server.ssh("sudo apt-get update")
server.recipie(:setup_quicktravel_app)
server.recipie(:setup_quicktravel_app_manual_dependencies)
server.recipie(:setup_quicktravel_ruby)

server.scp("nginx.site.example.conf", '/home/capistrano/nginx.site.example.conf')
server.scp("nginx.sites.defaults.conf", '/home/capistrano/nginx.sites.defaults.conf')
server.recipie(:setup_nginx)

