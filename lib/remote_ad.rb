# frozen_string_literal: true

require 'json'
require 'httparty'
require_relative 'configuration/remote_ad'
require_relative 'errors'

module RemoteAd
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration::RemoteAd.run
    end

    def fetch
      JSON.parse(HTTParty.get(configure.url).body)['ads'].map do |remote_ad|
        OpenStruct.new(remote_ad)
      end
    rescue JSON::ParserError, TypeError => e
      raise Errors::RemoteAdFetchError, 'Error while fetching data from' \
                                       "#{configure.url} with #{e.message}"
    end
  end
end
