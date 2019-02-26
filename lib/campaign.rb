# frozen_string_literal: true

require 'json'
require_relative 'configuration/campaign'
require_relative 'errors'

module Campaign
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration::Campaign.run
    end

    def find_by(key, value)
      fetch.find { |campaign| campaign.send(key) == value }
    end

    def without_remote_ad(not_in)
      fetch.select { |campaign| !not_in.include?(campaign.external_reference) }
    end

    private

    def fetch
      configure.campaigns
    end
  end
end
