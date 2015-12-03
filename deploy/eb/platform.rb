module Eb
  class Platform
    def initialize(opts)
      @eb = opts[:eb]
      @tag = opts[:tag]
    end

    def deploy!
      fail "Environment NOT READY!" unless @eb.ready?
      check_version
      eb_deploy!
    end

    private
    def eb_label_exists?
      eb_options =
        {application_name: @eb.application_name, version_labels: [@tag]}
      eb_response = @eb.describe_application_versions(eb_options)
      ! @eb.response.application_versions.empty?
    end

    def check_version
      puts "Checking the Beanstalk..."
      if eb_label_exists?
        puts "Elastic Beanstalk application #{@eb.application_name}"\
             " already has version #{@tag}"
        puts "Assuming you do mean to redeploy, perhaps to a new target."
        @use_existing = true
      else
        puts "Elastic Beanstalk doesn't have this version but tag exists."\
             "This usually indicates a recently failed deployment."
        puts "THIS SHOULD NOT HAPPEN. DEPLOY ANYWAY? (Y/N)"
        yoloswag = STDIN.gets
        fail 'Deployment killed, fix your repo' unless yoloswag.start_with?('y')
      end
    end

    def eb_deploy!
      if @use_existing
        system("eb deploy --version=#{tag}")
      else
        system("eb deploy --label=#{tag}")
      end
    end
  end
end
