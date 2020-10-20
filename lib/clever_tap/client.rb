require 'faraday'

class CleverTap
  class NotConsistentArrayError < RuntimeError
    def message
      'Some elements in the collection are of different type than the others'
    end
  end

  class Client
    DOMAIN = 'https://api.clevertap.com'.freeze
    API_VERSION = 1
    HTTP_PATH = 'upload'.freeze
    DEFAULT_SUCCESS = proc { |r| r.to_s }
    DEFAULT_FAILURE = proc { |r| r.to_s }

    ACCOUNT_HEADER = 'X-CleverTap-Account-Id'.freeze
    PASSCODE_HEADER = 'X-CleverTap-Passcode'.freeze

    attr_accessor :account_id, :passcode, :configure, :on_success, :on_failure

    def initialize(account_id = nil, passcode = nil, &configure)
      @account_id = assign_account_id(account_id)
      @passcode = assign_passcode(passcode)
      @configure = configure || proc {}
      @on_success = DEFAULT_SUCCESS
      @on_failure = DEFAULT_FAILURE
    end

    def connection
      # TODO: pass the config to a block
      @connection ||= Faraday.new("#{DOMAIN}/#{API_VERSION}") do |config|
        configure.call(config)

        # NOTE: set adapter only if there isn't one set
        config.adapter :net_http if config.builder.handlers.empty?

        config.headers['Content-Type'] = 'application/json'
        config.headers[ACCOUNT_HEADER] = account_id
        config.headers[PASSCODE_HEADER] = passcode
      end
    end

    def post(*args, &block)
      connection.post(*args, &block)
    end

    def get(*args, &block)
      connection.get(*args, &block)
    end

    def on_successful_upload(&block)
      @on_success = block
    end

    def on_failed_upload(&block)
      @on_failure = block
    end

    def upload(records, dry_run: 0)
      payload = ensure_array(records)
      entity = determine_type(payload)
      all_responses = []
      batched_upload(entity, payload, dry_run) do |response|
        all_responses << response
      end

      all_responses
    end

    def create_campaign(campaign)
      if campaign.receivers_limit_exceeded?
        bulk_create_campaign(campaign)
      else
        CampaignCreator.new(campaign).call(self)
      end
    end

    def bulk_create_campaign(campaign)
      campaigns = obtain_receivers(campaign)
      responses = []

      campaigns.each do |item|
        next if item.empty?
        campaign.to = item
        responses << CampaignCreator.new(campaign).call(self)
      end

      responses
    end

    private

    def obtain_receivers(campaign)
      campaigns = []
      temporal_receivers = {}
      identities = campaign.to.map { |k, v| [k, v] }
      identity_index = 0
      receivers_index = 0
      slots = Campaign::MAX_USERS_PER_CAMPAIGN

      while identity_index < identities.size
        key = identities[identity_index][0]
        receivers = identities[identity_index][1]
        size = receivers.size

        remaining_receivers = size - receivers_index

        current_slots = slots - remaining_receivers

        temporal_receivers[key] = [] unless temporal_receivers[key]

        if current_slots <= 0
          temporal_receivers[key] += receivers.slice(receivers_index, slots)

          receivers_index = remaining_receivers + current_slots
          slots = Campaign::MAX_USERS_PER_CAMPAIGN # 4

          campaigns << temporal_receivers unless temporal_receivers.empty?
          temporal_receivers = {}
        else
          temporal_receivers[key] += receivers.slice(receivers_index, remaining_receivers)
          receivers_index += remaining_receivers
          slots = current_slots
        end

        next unless remaining_receivers <= 1 || receivers[receivers_index].nil?

        identity_index += 1
        receivers_index = 0

        campaigns << temporal_receivers if identity_index >= identities.size && !temporal_receivers.empty?
      end

      campaigns
    end

    def batched_upload(entity, payload, dry_run)
      payload.each_slice(entity.upload_limit) do |group|
        response = post(HTTP_PATH, request_body(group)) do |request|
          request.params.merge!(dryRun: dry_run)
        end

        clevertap_response = Response.new(response)

        if clevertap_response.success
          @on_success.call(clevertap_response)
        else
          @on_failure.call(clevertap_response)
        end

        yield(clevertap_response) if block_given?
      end
    end

    def request_body(records)
      { 'd' => records.map(&:to_h) }.to_json
    end

    def determine_type(records)
      types = records.map(&:class).uniq
      raise NotConsistentArrayError unless types.one?
      types.first
    end

    def ensure_array(records)
      Array(records)
    end

    def assign_account_id(account_id)
      account_id || CleverTap.account_id || raise('Clever Tap `account_id` missing')
    end

    def assign_passcode(passcode)
      passcode || CleverTap.account_passcode || raise('Clever Tap `passcode` missing')
    end
  end
end
