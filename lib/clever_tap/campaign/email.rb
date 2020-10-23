class CleverTap
  class Campaign::Email < Campaign
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
      sender_name = @content.to_h['sender_name'] || @content.to_h[:sender_name]
      subject = @content.to_h['subject'] || @content.to_h[:subject]

      (body.nil? || sender_name.nil? || subject.nil?)
    end
  end
end
