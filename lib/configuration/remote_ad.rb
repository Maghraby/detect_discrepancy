# frozen_string_literal: true

module Configuration
  class RemoteAd
    attr_accessor :url

    def initialize
      @url = ENV['REMOTE_AD_URL'] || 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df'
    end

    def self.run
      new
    end
  end
end
