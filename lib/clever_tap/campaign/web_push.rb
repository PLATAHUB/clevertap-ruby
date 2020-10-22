class CleverTap
  class Campaign::WebPush < Campaign
    def initialize(**args)
      super(**args)
    end

    def to_h
      super.merge(content_hash)
    end

    def content_hash
      raise NoContentError if @content.to_h.empty?
      raise NoContentError if validate_content

      platform_specific = platform_specific_hash
      @content.merge!(platform_specific) unless platform_specific.empty?

      { CONTENT => @content }
    end

    def platform_specific_hash
      return {} unless @platform_specific

      { PLATFORM_SPECIFIC => @platform_specific }
    end

    private

    def validate_content
      body = @content.to_h['body'] || @content.to_h[:body]
      title = @content.to_h['title'] || @content.to_h[:title]

      (body.nil? || title.nil?)
    end

    def content_platform_specific
      @platform_specific ||= @content[:platform_specific]
      @platform_specific ||= @content['platform_specific']
    end
  end
end
