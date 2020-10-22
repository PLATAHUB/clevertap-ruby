class CleverTap
  class CampaignCreator
    HTTP_PATH = 'send/'.freeze

    TYPE_SMS = :sms
    TYPE_PUSH = :push
    TYPE_WEBPUSH = :web_push
    TYPE_EMAIL = :email

    CAMPAIGNS_NOTIFICATIONS_ENDPOINTS = {
      TYPE_SMS => 'sms.json',
      TYPE_PUSH => 'push.json',
      TYPE_WEBPUSH => 'webpush.json',
      TYPE_EMAIL => 'email.json'
    }.freeze

    attr_reader :record, :type

    def initialize(record)
      @record = record
      @type = campaign_type(record)
    end

    def call(client)
      uri = HTTP_PATH + CAMPAIGNS_NOTIFICATIONS_ENDPOINTS[type]
      response = client.post(uri, record.to_h.to_json)
      parse_response(response)
    end

    private

    def campaign_type(record)
      case record
      when CleverTap::Campaign::Sms
        TYPE_SMS
      when CleverTap::Campaign::WebPush
        TYPE_WEBPUSH
      when CleverTap::Campaign::Push
        TYPE_PUSH
      when CleverTap::Campaign::Email
        TYPE_EMAIL
      else
        TYPE_SMS
      end
    end

    def parse_response(http_response)
      http_response
    end
  end
end
