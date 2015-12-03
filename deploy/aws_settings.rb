class AwsSettings
  REGION='ap-southeast-2'

  # Get into Sydney
  def self.set_region!
    Aws.config.update(region: REGION)
  end
end
