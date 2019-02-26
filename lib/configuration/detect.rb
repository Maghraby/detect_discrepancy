# frozen_string_literal: true

module Configuration
  class Detect
    attr_accessor :mapping_keys

    MAPPING_KEYS = {
      status: :status,
      ad_description: :description
    }.freeze

    def initialize
      @mapping_keys = begin
                        JSON.parse(ENV['MAPPING_KEYS'])
                      rescue JSON::ParserError, TypeError
                        MAPPING_KEYS
                      end
    end

    def self.run
      new.mapping_keys
    end
  end
end
