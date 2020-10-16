class CleverTap
  class NoContentError < RuntimeError
    def message
      'No `content` param provided for Campaign'
    end
  end

  class NoReceiversError < RuntimeError
    def message
      'No `to` param provided for Campaign'
    end
  end

  class InvalidIdentityTypeError < RuntimeError
    def message
      'The identities types are not valid for Campaigns'
    end
  end

  class ReceiversLimitExceededError < RuntimeError
    def message
      'The max users per campaign limit was exceeded'
    end
  end

  class NoChannelIdError < RuntimeError
    def message
      'Channel Id (wzrk_cid) must be sent'
    end
  end

  class Campaign
    ALLOWED_IDENTITIES = %w[FBID Email Identity objectId GPID ID].freeze
    TO_STRING = 'to'.freeze
    TAG_GROUP = 'tag_group'.freeze
    CAMPAIGN_ID = 'campaign_id'.freeze
    CONTENT = 'content'.freeze
    PROVIDER_NICK_NAME = 'provider_nick_name'.freeze
    NOTIFICATION_SENT = 'notification_sent'.freeze
    RESPECT_FREQUENCY_CAPS = 'respect_frequency_caps'.freeze
    WZRK_CID = 'wzrk_cid'.freeze
    BADGE_ID = 'badge_id'.freeze
    BADGE_ICON = 'badge_icon'.freeze
    MUTABLE_CONTENT = 'mutable-content'.freeze
    PLATFORM_SPECIFIC = 'platform_specific'.freeze
    MAX_USERS_PER_CAMPAIGN = 1000

    def initialize(to:,
                   content:,
                   tag_group: nil,
                   campaign_id: nil,
                   provider_nick_name: nil,
                   notification_sent: nil,
                   respect_frequency_caps: nil,
                   wzrk_cid: nil,
                   badge_id: nil,
                   badge_icon: nil,
                   mutable_content: nil,
                   platform_specific: nil)
      @to = to
      @tag_group = tag_group
      @campaign_id = campaign_id
      @content = content
      @provider_nick_name = provider_nick_name
      @notification_sent = notification_sent
      @respect_frequency_caps = respect_frequency_caps
      @wzrk_cid = wzrk_cid
      @badge_id = badge_id
      @badge_icon = badge_icon
      @mutable_content = mutable_content
      @platform_specific = platform_specific || content_platform_specific
    end

    def to_h
      receivers_hash
        .merge(tag_group_hash)
        .merge(content_hash)
        .merge(provider_nick_name_hash)
        .merge(notification_sent_hash)
        .merge(respect_frequency_caps_hash)
        .merge(badge_id_hash)
        .merge(badge_icon_hash)
        .merge(mutable_content_hash)
    end

    def receivers_hash
      raise NoReceiversError if @to.to_h.empty?
      raise InvalidIdentityTypeError unless allowed?(@to.keys)
      raise NoReceiversError if @to.values.all?(&:empty?)
      raise ReceiversLimitExceededError if @to.values.map(&:size).reduce(&:+) > MAX_USERS_PER_CAMPAIGN

      { TO_STRING => @to }
    end

    def tag_group_hash
      return {} unless @tag_group
      { TAG_GROUP => @tag_group }
    end

    def campaign_id_hash
      return {} unless @campaign_id
      { CAMPAIGN_ID => @campaign_id }
    end

    def content_hash
      raise NoContentError if @content.to_h.empty?
      raise NoContentError if @content.to_h['body'].nil?

      platform_specific = platform_specific_hash
      @content.merge!(platform_specific) unless platform_specific.empty?

      { CONTENT => @content }
    end

    def provider_nick_name_hash
      return {} unless @provider_nick_name
      { PROVIDER_NICK_NAME => @provider_nick_name }
    end

    def notification_sent_hash
      return {} unless @notification_sent
      { NOTIFICATION_SENT => @notification_sent }
    end

    def respect_frequency_caps_hash
      return {} if @respect_frequency_caps.nil?
      { RESPECT_FREQUENCY_CAPS => @respect_frequency_caps }
    end

    def wzrk_cid_hash
      return {} unless @wzrk_cid
      { WZRK_CID => @wzrk_cid }
    end

    def badge_id_hash
      return {} unless @badge_id
      { BADGE_ID => @badge_id }
    end

    def badge_icon_hash
      return {} unless @badge_icon
      { BADGE_ICON => @badge_icon }
    end

    def mutable_content_hash
      return {} if @mutable_content.nil?
      { MUTABLE_CONTENT => @mutable_content }
    end

    def platform_specific_hash
      return {} unless @platform_specific

      android = @platform_specific[:android] || @platform_specific['android']

      if android
        channel = @wzrk_cid || android[:wzrk_cid] || android['wzrk_cid']
        raise NoChannelIdError unless channel

        @platform_specific['android']['wzrk_cid'] = channel
      end

      { PLATFORM_SPECIFIC => @platform_specific }
    end

    def content_platform_specific
      @platform_specific ||= @content[:platform_specific]
      @platform_specific ||= @content['platform_specific']
    end

    def allowed?(indentities)
      (indentities - ALLOWED_IDENTITIES).empty?
    end
  end
end
