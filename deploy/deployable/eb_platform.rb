class EBPlatform
  def deploy(application)
    fail "Environment NOT READY!" unless application.platform_config.ready?
    system("eb-deploy-tag #{TAG}")
  end
end
