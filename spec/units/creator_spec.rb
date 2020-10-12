require 'spec_helper'

describe CleverTap::Creator, vcr: true do
  describe '#call' do
    let(:client) { CleverTap::Client.new(AUTH_ACCOUNT_ID, AUTH_PASSCODE) }

    context 'sms' do
      let(:campaign) do
        CleverTap::Campaign.new(
          to: { 'Email' => ['john@doe.com'] },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        )
      end

      subject { described_class.new(campaign) }

      context 'with valid data' do
        it 'creates a new campaign' do
          result = subject.call(client)
          body = JSON.parse(result.body)

          aggregate_failures 'success response' do
            expect(result.success?).to be_truthy
            expect(result.status).to eq(200)
            expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
          end
        end
      end
    end

    context 'web_push' do
      let(:campaign) do
        CleverTap::Campaign.new(
          to: {
            'FBID' => %w[
              102029292929388
              114342342453463
            ],
            'Email' =>  [
              'john@doe.com',
              'jane@doe.com'
            ],
            'Identity' => [
              'JohnDoe'
            ],
            'objectId' => [
              '_asdnkansdjknaskdjnasjkndja',
              '-adffajjdfoaiaefiohnefwprjf'
            ]
          },
          tag_group: 'my tag group',
          campaign_id: 1_000_000_043,
          respect_frequency_caps: false,
          content: {
            'title' => 'Hi!',
            'body' => 'How are you doing today?',
            'platform_specific' => {
              'safari' => {
                'deep_link' => 'https://www.google.com',
                'ttl' => 10
              },
              'chrome' => {
                'image' => 'https://www.exampleImage.com',
                'icon' => 'https://www.exampleIcon.com',
                'deep_link' => 'http://www.example.com',
                'ttl' => 10,
                'require_interaction' => true,
                'cta_title1' => 'title',
                'cta_link1' => 'http://www.example2.com',
                'cta_iconlink1' => 'https://www.exampleIcon2.com'
              },
              'firefox' => {
                'icon' => 'https://www.exampleIcon.com',
                'deep_link' => 'https://www.google.com',
                'ttl' => 10
              }
            }
          }
        )
      end

      subject { described_class.new(campaign, :web_push) }
      context 'with valid data' do
        it 'creates a new campaign' do
          result = subject.call(client)
          body = JSON.parse(result.body)

          aggregate_failures 'success response' do
            expect(result.success?).to be_truthy
            expect(result.status).to eq(200)
            expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
          end
        end
      end
    end

    context 'push' do
      let(:campaign) do
        CleverTap::Campaign.new(
          to: {
            'FBID' => %w[
              102029292929388
              114342342453463
            ],
            'GPID' => [
              '1928288389299292'
            ],
            'Email' => [
              'john@doe.com',
              'jane@doe.com'
            ],
            'Identity' => [
              'JohnDoe'
            ],
            'objectId' => [
              '_asdnkansdjknaskdjnasjkndja',
              '-adffajjdfoaiaefiohnefwprjf'
            ]
          },
          tag_group: 'my tag group',
          respect_frequency_caps: false,
          content: {
            'title' => 'Welcome',
            'body' => 'Hello world!',
            'platform_specific' => {
              'ios' => {
                'deep_link' => 'example.com',
                'sound_file' => 'example.caf',
                'category' => 'notification category',
                'badge_count' => 1,
                'key' => 'value_ios'
              },
              'android' => {
                'background_image' => 'http://example.jpg',
                'default_sound' => true,
                'deep_link' => 'example.com',
                'large_icon' => 'http://example.png',
                'key' => 'value_android'
              }
            }
          }
        )
      end

      subject { described_class.new(campaign, :push) }

      xcontext 'with valid data push' do
        it 'creates a new campaign' do
          result = subject.call(client)
          body = JSON.parse(result.body)

          aggregate_failures 'success response' do
            expect(result.success?).to be_truthy
            expect(result.status).to eq(200)
            expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
          end
        end
      end
    end

    context 'email' do
      let(:campaign) do
        CleverTap::Campaign.new(
          to: {
            'FBID' => %w[
              102029292929388
              114342342453463
            ],
            'GPID' => [
              '1928288389299292'
            ],
            'Email' => [
              'john@doe.com',
              'jane@doe.com'
            ],
            'Identity' => [
              'JohnDoe'
            ],
            'objectId' => [
              '_asdnkansdjknaskdjnasjkndja',
              '-adffajjdfoaiaefiohnefwprjf'
            ]
          },
          tag_group: 'my tag group',
          respect_frequency_caps: false,
          content: {
            'subject' => 'Welcome',
            'body' => '<div>Your HTML content for the email</div>',
            'sender_name' => 'CleverTap'
          }
        )
      end

      subject { described_class.new(campaign, :email) }

      context 'with valid data email' do
        it 'creates a new campaign' do
          result = subject.call(client)
          body = JSON.parse(result.body)

          aggregate_failures 'success response' do
            expect(result.success?).to be_truthy
            expect(result.status).to eq(200)
            expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
          end
        end
      end
    end
  end
end
