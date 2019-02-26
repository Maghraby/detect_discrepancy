# frozen_string_literal: true

module Configuration
  class Campaign
    attr_accessor :campaigns, :mapping_values

    MAPPING_VALUES = {
      status: {
        'active' => 'enabled',
        'paused' => 'disabled'
      }
    }.freeze

    def initialize
      @mapping_values = begin
                          JSON.parse(ENV['MAPPING_VALUES'])
                        rescue JSON::ParserError, TypeError
                          MAPPING_VALUES
                        end

      @campaigns = YAML.load_file('config/campaigns.yml').map do |campaign|
        create_campaign(campaign)
      end
    end

    def self.run
      new
    end

    private

    def create_campaign(campaign)
      mapping_values.each do |key, hash|
        campaign["mapping_#{key}"] = hash[campaign[key.to_s]]
      end

      OpenStruct.new(campaign)
    end
  end
end
