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
    unless eb_label_exists?
      fail "Elastic Beanstalk doesn't have this version but tag exists."\
           "This should not happen. Fix your repo man."\
           "This usually indicates a recently failed deployment."
    else
      puts "Elastic Beanstalk application #{eb.application_name}"\
           " already has version #{@tag}"
      puts "Assuming you do mean to redeploy, perhaps to a new target."
    end
  end

  end
end
