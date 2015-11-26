class EBPlatform
  def deploy(application)
    @application = application
    fail "Environment NOT READY!" unless eb.ready?
  end

  private
  def eb
    @eb ||= @application.platform_config
  end

  end
end
