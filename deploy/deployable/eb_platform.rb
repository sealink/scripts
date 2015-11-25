class EBPlatform
  def deploy(application)
    @application = application
    fail "Environment NOT READY!" unless @application.platform_config.ready?
  end
end
