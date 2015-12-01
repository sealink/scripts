class EBPlatform
  def deploy(application)
    @application = application
    fail "Environment NOT READY!" unless eb.ready?
    @tag = @application.tag
    check_version!
  end

  private
  def eb
    @eb ||= @application.platform_config
  end

  def eb_label_exists?
    eb_response =
      eb.describe_application_versions(application_name: eb.application_name,
                                       version_labels: [@tag])
    ! eb.response.application_versions.empty?
  end

  def check_version!
    puts "Tag #{application.tag} already exists in Git."
    puts "Checking the Beanstalk..."
    if eb_label_exists?
      puts "Elastic Beanstalk application #{eb.application_name}"\
           " already has version #{@tag}"
      puts "Assuming you do mean to redeploy, perhaps to a new target."
      @use_existing ||= true
    else
      puts "Elastic Beanstalk doesn't have this version but tag exists."\
           "This usually indicates a recently failed deployment."
      puts "THIS SHOULD NOT HAPPEN. DEPLOY ANYWAY? (Y/N)"
      yoloswag = STDIN.gets
      fail 'Deployment aborted, fix your repo' unless yoloswag.start_with?('y')
    end
  end

  end
end
