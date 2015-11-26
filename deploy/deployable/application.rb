class Application
  attr_reader :name, :tag, :repo
  attr_accessor :platform, :platform_config

  def initialize(opts = {})
    @app = opts[:app]
    @name = @app.key.sub('/', '')
    @repo = opts[:repo]
    @tag  = opts[:tag]
  end

  def deploy
    fail 'Deployment platform not set' unless @platform
    @platform.deploy(self)
  end

  def to_s
    "#{@name} #{@tag}"
  end

  def tag_exists?
    @repo.tags.map(&:name).include? @tag
  end
end
