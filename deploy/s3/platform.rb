module S3
  class Platform
    def deploy!(application)
      @application = application
      @tag = @application.tag
      s3_deploy!
    end

    private
    def s3
      @s3 ||= @application.platform_config
    end

    def s3_deploy!
      system(
        "bucket=#{s3.target_bucket}"\
        " s3_config_version=#{s3.version}"\
        " npm run publish"
      )
    end
  end
end
