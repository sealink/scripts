class S3Platform
  def deploy(application)
    @application = application
    # Provide the configuration versions and let user choose
    puts "Version \"#{version}\" selected."
    system("s3-deploy-tag #{TAG}")
  end

  def version
    version_folders = @application.platform_config.versions
    versions = version_folders.map{|obj| obj.key.split('/').last }
    puts "Found configurations. Select index of the one to deploy:"
    versions.each_with_index do |version, index|
      printf "%s\t%s\n", version, index
    end
    version_index = Integer(STDIN.gets)
    versions[version_index]
  end
end
