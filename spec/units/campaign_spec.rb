require 'spec_helper'

RSpec.describe CleverTap::Campaign do
  describe '#to_h' do
    subject { described_class.new(**params).to_h }

    let(:params) do
      {
        to: {
          'Email' => ['example@email.com'],
          'FBID' => ['fbidexample']
        },
        tag_group: 'mytaggroup',
        respect_frequency_caps: false,
        content: { 'body' => 'Smsbody' }
      }
    end

    let(:parsed_params) { Hash[params.map { |k, v| [k.to_s, v] }] }

    context "When 'to' key is not defined" do
      let(:params) do
        {
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a ArgumentError error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "When 'to' key is empty" do
      let(:params) do
        {
          to: {},
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a NoReceiversError error' do
        expect { subject }.to raise_error(CleverTap::NoReceiversError)
      end
    end

    context 'When identity key into to is invalid' do
      let(:params) do
        {
          to: {
            'BadIdentity' => ['example']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a InvalidIdentityTypeError error' do
        expect { subject }.to raise_error(CleverTap::InvalidIdentityTypeError)
      end
    end

    context 'When indentity keys are empty' do
      let(:params) do
        {
          to: {
            'FBID' => [],
            'Email' => [],
            'Identity' => [],
            'objectId' => []
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a NoReceiversError error' do
        expect { subject }.to raise_error(CleverTap::NoReceiversError)
      end
    end

    context 'When identity keys are not empty' do
      it { is_expected.to eq parsed_params }
    end

    context 'When content data is sent' do
      before do
        params.merge!(
          content: {
            'title' => 'Test title',
            'subject' => 'example',
            'body' => 'Smsbody',
            'sender_name' => 'example'
          }
        )
      end

      it { is_expected.to eq parsed_params }
    end

    context 'When content is not sent' do
      before do
        params.delete :content
      end

      it 'should raise a ArgumentError error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'When content body is not sent' do
      before do
        params[:content].delete 'body'
      end

      it 'should raise a NoContentError error' do
        expect { subject }.to raise_error(CleverTap::NoContentError)
      end
    end

    context 'When users per campaign limit was exceeded' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'] * 100,
            'FBID' => ['fbidexample'] * 901
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a ReceiversLimitExceededError error' do
        expect { subject }.to raise_error(CleverTap::ReceiversLimitExceededError)
      end
    end

    context 'When platform_specific is sended as param' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' },
          platform_specific:  { # Optional
            'safari' => {
              'deep_link' => 'https://apple.com',
              'ttl' => 10
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end

    context 'When platform_specific is sended into content (Symbol)' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'body' => 'Smsbody',
            platform_specific:  { # Optional
              'safari' => {
                'deep_link' => 'https://apple.com',
                'ttl' => 10
              }
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end

    context 'When platform_specific is sended into content' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'body' => 'Smsbody',
            'platform_specific' =>  { # Optional
              'safari' => {
                'deep_link' => 'https://apple.com',
                'ttl' => 10
              }
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end

    context 'When platform_specific has android section, without channel' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'body' => 'Smsbody',
            'platform_specific' =>  { # Optional
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
        }
      end

      it 'should raise a NoChannelIdError error' do
        expect { subject.call(client) }.to raise_error(CleverTap::NoChannelIdError)
      end
    end

    context 'When platform_specific has android section, with channel' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'body' => 'Smsbody',
            'platform_specific' =>  { # Optional
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
                'key' => 'value_android',
                'wzrk_cid' => 'engagement'
              }
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end
  end
end
