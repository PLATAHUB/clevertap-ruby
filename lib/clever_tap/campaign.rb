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

  class InvalidIdentityType < RuntimeError
    def message
      'The identities types are not valid for Campaigns'
    end
  end

  class Campaign
    ALLOWED_IDENTITIES = %w[FBID Email Identity objectId GPID ID].freeze
    TO_STRING = 'to'.freeze
    TAG_GROUP = 'tag_group'.freeze
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

    def initialize(**args)
      @to = args[:to]
      @tag_group = args[:tag_group]
      @content = args[:content]
      @provider_nick_name_pair = args[:provider_nick_name_pair]
      @notification_sent = args[:notification_sent]
      @respect_frequency_caps = args[:respect_frequency_caps]
      @wzrk_cid = args[:wzrk_cid]
      @badge_id = args[:badge_id]
      @badge_icon = args[:badge_icon]
      @mutable_content = args[:mutable_content]
      @platform_specific = args[:platform_specific]
    end

    def to_h
      put_to_pair
        .merge(put_tag_group_pair)
        .merge(put_content_pair)
        .merge(put_provider_nick_name_pair)
        .merge(put_notification_sent_pair)
        .merge(put_respect_frequency_caps_pair)
        .merge(put_wzrk_cid_pair)
        .merge(put_badge_id_pair)
        .merge(put_badge_icon_pair)
        .merge(put_mutable_content_pair)
        .merge(put_platform_specific_pair)
    end

    def put_to_pair
      raise NoReceiversError if @to.to_h.empty?
      raise InvalidIdentityType unless allowed?(@to.keys)
      raise NoReceiversError if @to.values.all?(&:empty?)

      { TO_STRING => @to }
    end

    def put_tag_group_pair
      return {} unless @tag_group
      { TAG_GROUP => @tag_group }
    end

    def put_content_pair
      raise NoContentError if @content.to_h.empty?
      raise NoContentError if @content.to_h['body'].nil?

      { CONTENT => @content }
    end

    def put_provider_nick_name_pair
      return {} unless @provider_nick_name_pair
      { PROVIDER_NICK_NAME => @provider_nick_name_pair }
    end

    def put_notification_sent_pair
      return {} unless @notification_sent
      { NOTIFICATION_SENT => @notification_sent }
    end

    def put_respect_frequency_caps_pair
      return {} if @respect_frequency_caps.nil?
      { RESPECT_FREQUENCY_CAPS => @respect_frequency_caps }
    end

    def put_wzrk_cid_pair
      return {} unless @wzrk_cid
      { WZRK_CID => @wzrk_cid }
    end

    def put_badge_id_pair
      return {} unless @badge_id
      { BADGE_ID => @badge_id }
    end

    def put_badge_icon_pair
      return {} unless @badge_icon
      { BADGE_ICON => @badge_icon }
    end

    def put_mutable_content_pair
      return {} if @mutable_content.nil?
      { MUTABLE_CONTENT => @mutable_content }
    end

    def put_platform_specific_pair
      return {} unless @platform_specific
      { PLATFORM_SPECIFIC => @platform_specific }
    end

    def allowed?(indentities)
      (indentities - ALLOWED_IDENTITIES).empty?
    end
  end
end
