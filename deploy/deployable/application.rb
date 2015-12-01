require_relative 'repository'

class Application
  attr_reader :name, :tag, :repo
  attr_accessor :platform, :platform_config

  def initialize(opts = {})
    @app = opts[:app]
    @name = @app.key.sub('/', '')
    @tag  = opts[:tag]
    @repo = Deployable::Repository.new
    @repo.tag = @tag
  end

  def deploy
    fail 'Deployment platform not set' unless @platform
    @platform.deploy(self)
  end

  def to_s
    "#{@name} #{@tag}"
  end

  def tag_exists?
    @repo.tag_exists?(@tag)
  end

  def sync!
    @repo.sync!
  end
end
