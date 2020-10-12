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

      it 'should raise a NoReceiversError error' do
        expect { subject }.to raise_error(CleverTap::NoReceiversError)
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

      it 'should raise a InvalidIdentityType error' do
        expect { subject }.to raise_error(CleverTap::InvalidIdentityType)
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

      it 'should raise a NoContentError error' do
        expect { subject }.to raise_error(CleverTap::NoContentError)
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
  end
end