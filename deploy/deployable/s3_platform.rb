class S3Platform
  def deploy(application)
    system("s3-deploy-tag #{TAG}")
  end
end
