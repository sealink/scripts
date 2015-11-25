class EBConfiguration
  def initialize(env)
    @env = env
  end

  def exists?
    !environment_info.nil?
  end

  def environment_info
    @environment_info ||= environment_description_message.environments[0]
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
