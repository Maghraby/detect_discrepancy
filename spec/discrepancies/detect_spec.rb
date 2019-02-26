# frozen_string_literal: true

require 'spec_helper'
require 'byebug'

RSpec.describe 'Detect' do
  let(:subject) { Detect.run }
  describe '#run' do
    describe 'When there is no discrepancy' do
      context 'Mapping active to enabled' do
        let(:response) { [] }
        let(:remote_ads) do
          {
            "ads":
                [
                  {
                    "reference": '1',
                    "status": 'enabled',
                    "description": 'Description for campaign 11'
                  },
                  {
                    "reference": '2',
                    "status": 'enabled',
                    "description": 'Description for campaign 12'
                  },
                  {
                    "reference": '3',
                    "status": 'enabled',
                    "description": 'Description for campaign 13'
                  }
                ]
          }
        end

        before do
          WebMock.stub_request(:get, 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df')
                .to_return(status: 200, body: remote_ads.to_json, headers: { 'Content-type' => 'application/json' })

          campaigns = YAML.safe_load(File.read('spec/fixtures/campaigns_no_discrepancy.yml'))
          allow(Campaign).to receive(:find_by).with(:external_reference, 1).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[0]))
          allow(Campaign).to receive(:find_by).with(:external_reference, 2).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[1]))
          allow(Campaign).to receive(:find_by).with(:external_reference, 3).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[2]))
        end
        it 'get changes correctly' do
          expect(subject.errors).to eq []
          expect(subject.changes).to eq response
        end
      end

      describe "Mapping active to enabled and paused to disabled" do
        let(:response) { [] }
        let(:remote_ads) do
          {
            "ads":
                [
                  {
                    "reference": '1',
                    "status": 'enabled',
                    "description": 'Description for campaign 11'
                  },
                  {
                    "reference": '2',
                    "status": 'disabled',
                    "description": 'Description for campaign 12'
                  },
                  {
                    "reference": '3',
                    "status": 'enabled',
                    "description": 'Description for campaign 13'
                  }
                ]
          }
        end

        before do
          WebMock.stub_request(:get, 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df')
                .to_return(status: 200, body: remote_ads.to_json, headers: { 'Content-type' => 'application/json' })

          campaigns = YAML.safe_load(File.read('spec/fixtures/campaigns_no_discrepancy_paused_to_disabled.yml'))
          allow(Campaign).to receive(:find_by).with(:external_reference, 1).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[0]))
          allow(Campaign).to receive(:find_by).with(:external_reference, 2).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[1]))
          allow(Campaign).to receive(:find_by).with(:external_reference, 3).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[2]))
        end

        it 'get changes correctly' do
          expect(subject.errors).to eq []
          expect(subject.changes).to eq response
        end
      end
    end

    describe 'When there are discrepancy' do
      context 'status' do
        context 'map disabled to deleted' do
          let(:response) do
            [
              {
                remote_reference: '2',
                discrepancies: [
                  {
                    status: {
                      remote: 'disabled',
                      local: 'deleted'
                    }
                  },
                  {
                    ad_description: {
                      remote: 'Description for campaign 12',
                      local: nil
                    }
                  }
                ]
              },
              {
                remote_reference: '3',
                discrepancies: [
                  {
                    ad_description: {
                      remote: 'Description for campaign 13',
                      local: 'Description for campaign 33'
                    }
                  }
                ]
              }
            ]
          end

          let(:remote_ads) do
            {
              "ads":
                  [
                    {
                      "reference": '1',
                      "status": 'enabled',
                      "description": 'Description for campaign 11'
                    },
                    {
                      "reference": '2',
                      "status": 'disabled',
                      "description": 'Description for campaign 12'
                    },
                    {
                      "reference": '3',
                      "status": 'enabled',
                      "description": 'Description for campaign 13'
                    }
                  ]
            }
          end

          before do
            WebMock.stub_request(:get, 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df')
                  .to_return(status: 200, body: remote_ads.to_json, headers: { 'Content-type' => 'application/json' })

            campaigns = YAML.safe_load(File.read('spec/fixtures/campaigns_map_deleted_to_disabled.yml'))
            allow(Campaign).to receive(:find_by).with(:external_reference, 1).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[0]))
            allow(Campaign).to receive(:find_by).with(:external_reference, 2).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[1]))
            allow(Campaign).to receive(:find_by).with(:external_reference, 3).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[2]))
          end

          it 'should map successfully' do
            expect(subject.errors).to eq []
            expect(subject.changes).to_not eq []
            expect(subject.changes).to eq response
          end
        end

        context 'map disabled to paused' do
          let(:response) do
            [
              {
                remote_reference: '2',
                discrepancies: [
                  {
                    ad_description: {
                      remote: 'Description for campaign 12',
                      local: 'Description for campaign 22'
                    }
                  }
                ]
              },
              {
                remote_reference: '3',
                discrepancies: [
                  {
                    ad_description: {
                      remote: 'Description for campaign 13',
                      local: 'Description for campaign 33'
                    }
                  }
                ]
              }
            ]
          end

          let(:remote_ads) do
            {
              "ads":
                  [
                    {
                      "reference": '1',
                      "status": 'enabled',
                      "description": 'Description for campaign 11'
                    },
                    {
                      "reference": '2',
                      "status": 'disabled',
                      "description": 'Description for campaign 12'
                    },
                    {
                      "reference": '3',
                      "status": 'enabled',
                      "description": 'Description for campaign 13'
                    }
                  ]
            }
          end

          before do
            WebMock.stub_request(:get, 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df')
                  .to_return(status: 200, body: remote_ads.to_json, headers: { 'Content-type' => 'application/json' })

            campaigns = YAML.safe_load(File.read('spec/fixtures/campaigns_map_paused_to_disabled.yml'))
            allow(Campaign).to receive(:find_by).with(:external_reference, 1).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[0]))
            allow(Campaign).to receive(:find_by).with(:external_reference, 2).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[1]))
            allow(Campaign).to receive(:find_by).with(:external_reference, 3).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[2]))
          end

          it 'should map successfully' do
            expect(subject.errors).to eq []
            expect(subject.changes).to_not eq []
            expect(subject.changes).to eq response
          end
        end
      end

      context 'when have local campaign and no remote ad' do
        let(:response) do
          [
            {
              remote_reference: '2',
              discrepancies: [
                {
                  status: {
                    remote: 'disabled',
                    local: 'deleted'
                  }
                },
                {
                  ad_description: {
                    remote: 'Description for campaign 12',
                    local: nil
                  }
                }
              ]
            },
            {
              remote_reference: '3',
              discrepancies: [
                {
                  ad_description: {
                    remote: 'Description for campaign 13',
                    local: 'Description for campaign 33'
                  }
                }
              ]
            },
            {
              remote_reference: 4,
              discrepancies: [
                {
                  status: {
                    remote: nil,
                    local: 'active'
                  }
                },
                {
                  ad_description: {
                    remote: nil,
                    local: 'Description for campaign 44'
                  }
                }
              ]
            }
          ]
        end

        let(:remote_ads) do
          {
            "ads":
                [
                  {
                    "reference": '1',
                    "status": 'enabled',
                    "description": 'Description for campaign 11'
                  },
                  {
                    "reference": '2',
                    "status": 'disabled',
                    "description": 'Description for campaign 12'
                  },
                  {
                    "reference": '3',
                    "status": 'enabled',
                    "description": 'Description for campaign 13'
                  }
                ]
          }
        end

        before do
          WebMock.stub_request(:get, 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df')
                .to_return(status: 200, body: remote_ads.to_json, headers: { 'Content-type' => 'application/json' })

          campaigns = YAML.safe_load(File.read('spec/fixtures/campaigns_with_local_campaign_and_no_remote.yml'))
          allow(Campaign).to receive(:find_by).with(:external_reference, 1).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[0]))
          allow(Campaign).to receive(:find_by).with(:external_reference, 2).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[1]))
          allow(Campaign).to receive(:find_by).with(:external_reference, 3).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[2]))
          allow(Campaign).to receive(:find_by).with(:external_reference, 3).and_return(Configuration::Campaign.new.send(:create_campaign, campaigns[2]))
          allow(Campaign).to receive(:without_remote_ad).with([1,2,3]).and_return([Configuration::Campaign.new.send(:create_campaign, campaigns[3])])
        end

        it 'should map successfully' do
          expect(subject.errors).to eq []
          expect(subject.changes).to_not eq []
          expect(subject.changes).to eq response
        end
      end
    end
  end
end
