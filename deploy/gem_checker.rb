class GemChecker
  def self.require_gem(name, version=nil)
    if version
      gem name, "~> #{version}"
    else
      gem name
    end
    require name
  rescue LoadError
    fail "Run \'gem install #{name}\' first."
  end
end
