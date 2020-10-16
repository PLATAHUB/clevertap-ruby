class CleverTap
  class SmsCampaign < Campaign
    def initialize(**args)
      super(**args)
    end

    def to_h
      super.merge(content_hash)
    end

    def content_hash
      raise NoContentError if @content.to_h.empty?
      raise NoContentError if validate_content

      { CONTENT => @content }
    end

    private

    def validate_content
      body = @content.to_h['body'] || @content.to_h[:body]
      body.nil?
    end
  end
end
