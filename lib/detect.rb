# frozen_string_literal: true

require_relative 'remote_ad'
require_relative 'campaign'
require_relative 'configuration/detect'
require_relative 'errors'
require 'byebug'

class Detect
  attr_accessor :remote_ads, :mapping_keys, :errors, :changes

  def initialize
    self.mapping_keys ||= Configuration::Detect.run
    self.remote_ads   = []
    self.errors       = []
    self.changes      = []
  end

  def self.run
    new.run
  end

  def run
    fetch_remote_ads
    detect_discrepancies

    self
  end

  private

  def detect_discrepancies
    detect_remote_ads
    detect_local_campaigns
  end

  def detect_remote_ads
    remote_ads.each do |remote_ad|
      detect_discrepancy(remote_ad.reference, remote_ad,
                         Campaign.find_by(:external_reference,
                                          remote_ad.reference.to_i))
    end
  end

  def detect_local_campaigns
    Campaign.without_remote_ad(external_references).each do |campaign|
      detect_discrepancy(campaign.external_reference, nil, campaign)
    end
  end

  def detect_discrepancy(reference, remote_ad, campaign)
    changes = []

    mapping_keys.each do |key, mapping|
      changes << get_changes(key, mapping, remote_ad, campaign)
    end

    add_changes(reference, changes.compact)
  end

  def external_references
    @external_references ||= remote_ads.map(&:reference).map(&:to_i)
  end

  def get_changes(key, mapping, remote_ad, campaign)
    return unless remote_ad&.send(mapping) != (campaign&.send("mapping_#{key}") ||
                                               campaign&.send(key))

    {
      key.to_sym => {
        remote: remote_ad&.send(mapping),
        local: campaign&.send(key)
      }
    }
  end

  def add_changes(reference, changes)
    return if changes.empty?

    self.changes <<
      { remote_reference: reference,
        discrepancies: changes }
  end

  def fetch_remote_ads
    self.remote_ads = RemoteAd.fetch
  rescue Errors::RemoteAdFetchError => e
    errors << e
  end
end
