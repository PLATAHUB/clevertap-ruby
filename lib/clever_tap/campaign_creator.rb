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

    attr_reader :campaign, :type

    def initialize(campaign)
      @campaign = campaign
      @type = type_of(campaign)
    end

    def call(client)
      uri = HTTP_PATH + CAMPAIGNS_NOTIFICATIONS_ENDPOINTS[type]
      response = client.post(uri, campaign.to_h.to_json)
      parse_response(response)
    end

    private

    def type_of(campaign)
      case campaign
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
