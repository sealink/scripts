class Application
  attr_reader :name, :tag
  attr_accessor :platform, :platform_config

  def initialize(opts = {})
    @name     = opts[:name]
    @tag  = opts[:tag]
  end

  def deploy
    @platform.deploy(self)
  end

  def to_s
    "#{@name} #{@tag}"
  end
end
