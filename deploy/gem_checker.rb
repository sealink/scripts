class GemChecker
  def self.require_gem(params = {})
    gem_name = params[:gem_name]
    version = params[:gem_version]
    if version
      gem gem_name, "~> #{version}"
    else
      gem gem_name
    end
    require gem_name
  rescue LoadError
    fail "Run \'gem install #{gem_name}\' first."
  end
end
