module S3
  class Platform
    def deploy!(opts)
      @s3 = opts[:s3]
      @tag = opts[:tag]
      s3_deploy!
    end

    private
    def s3_deploy!
      system(
        "bucket=#{@s3.target_bucket}"\
        " s3_config_version=#{@s3.version}"\
        " npm run publish"
      )
    end
  end
end
