class Application
  attr_reader :name, :version
  attr_accessor :platform, :platform_config

  def initialize(opts = {})
    @name     = opts[:name]
    @version  = opts[:version]
  end

  def deploy
    @platform.deploy(self)
  end
end
