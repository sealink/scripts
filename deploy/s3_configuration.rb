class S3Configuration
  attr_reader :version
  def initialize(app_configs)
    @app_configs = app_configs
    @name = app_configs.key
  end

  def exists?
    target_bucket.exists?
  end

  def versions
    @versions ||= versions_list
  end

  private
  def target_bucket
    call_with_error_handling do
      Aws::S3::Bucket.new(name: @name)
    end
  end

  def versions_list
    call_with_error_handling do
      @app_configs.bucket.objects.select do |o|
        !o.key.empty? &&
        o.key.start_with?("#{@name}config/") &&
        o.key.end_with?('/') &&
        o.key.count('/') == 3
      end
    end
  end

  def call_with_error_handling
    yield
  rescue Aws::S3::Errors::ServiceError => e
    # rescues all errors returned by Amazon Simple Storage Service
    fail "Error thrown by AWS S3: #{e}"
  end
end
