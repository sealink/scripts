require_relative 'repository'

class Application
  attr_reader :name, :tag, :repo
  attr_accessor :platform, :platform_config

  def initialize(opts = {})
    @bucket = opts[:app_bucket]
    @tag  = opts[:tag]
  end

  def name
    @bucket ? @bucket.key.sub('/', '') : ''
  end

  def deploy!
    fail 'Deployment platform not set' unless @platform
    @platform.deploy!(self)
  end

  def to_s
    "#{name} #{@tag}"
  end

  def tag_exists?
    repo.tag_exists?(@tag)
  end

  def sync!
    repo.sync!
  end

  def repo
    @repo ||= Repository.new
  end
end
