module Eb
  class Configuration
    def initialize(app_configs)
      @app_configs = app_configs
      @env = app_configs.key.sub('/','')
    end

    def exists?
      !environment_info.nil?
    end

    def ready?
      environment_info.status.eql? 'Ready'
    end

    def environment_info
      @environment_info ||= environment_description_message.environments[0]
    end

    def application_name
      environment_info.application_name
    end

    private
    def elasticbeanstalk
      @elasticbeanstalk ||=
        call_with_error_handling { Aws::ElasticBeanstalk::Client.new }
    end

    def environment_description_message
      call_with_error_handling do
        elasticbeanstalk.describe_environments(
          environment_names: [@env]
        )
      end
    end

    def call_with_error_handling
      yield
    rescue Aws::ElasticBeanstalk::Errors::ServiceError => e
      # rescues all errors returned by Amazon Elastic Beanstalk
      fail "Error thrown by AWS EB: #{e}"
    end
  end
end
