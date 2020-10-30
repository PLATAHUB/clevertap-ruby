class CleverTap
  # Introduce unified interface as the `SuccessfulResponse`
  class FailedResponse
    FAIL_STATUS = 'fail'.freeze

    attr_reader :records, :message, :code

    def initialize(records: nil, message: nil, code: -1)
      raise ArgumentError, 'required keyword: records, message' if records.nil? && message.nil?
      raise ArgumentError, 'required keyword: records' if records.nil?
      raise ArgumentError, 'required keyword: message' if message.nil?

      @records = records
      @message = message
      @code = code
    end

    def status
      FAIL_STATUS
    end

    def success
      false
    end

    def errors
      records.map do |record|
        { 'status' => FAIL_STATUS, 'code' => code, 'error' => message, 'record' => record }
      end
    end
  end
end
