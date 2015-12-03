module Eb
  class Platform
    def initialize(opts)
      @eb = opts[:eb]
      @tag = opts[:tag]
    end

    def deploy!
      fail "Environment NOT READY!" unless @eb.ready?
      eb_deploy!
    end

    private
    def eb_label_exists?
      eb_options =
        {application_name: @eb.application_name, version_labels: [@tag]}
      eb_response = @eb.describe_application_versions(eb_options)
      ! @eb.response.application_versions.empty?
    end

    def write_redeploy_notification
      puts "Elastic Beanstalk application #{@eb.application_name}"\
           " already has version #{@tag}"
      puts "Assuming you do mean to redeploy, perhaps to a new target."
    end

    def eb_deploy!
      if eb_label_exists?
        write_redeploy_notification
        system("eb deploy --version=#{@tag}")
      else
        system("eb deploy --label=#{@tag}")
      end
    end
  end
end
