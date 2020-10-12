class CleverTap
  class Creator
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

    def initialize(record, type = :sms)
      @record = record
      @type = type
    end

    def call(client)
      uri = HTTP_PATH + CAMPAIGNS_NOTIFICATIONS_ENDPOINTS[type]
      response = client.post(uri, record.to_h.to_json)
      parse_response(response)
    end

    private

    def parse_response(http_response)
      http_response
    end
  end
end
