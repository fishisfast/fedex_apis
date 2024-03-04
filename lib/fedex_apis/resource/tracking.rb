module FedexApis
  module Resource
    class Tracking < OpenStruct
      attr_reader :status

      SUCCESS_STATUSES = [200].freeze

      def initialize(status, body)
        @status = status
        super(JSON.parse(body))
      end

      def success?
        SUCCESS_STATUSES.include?(status)
      end
    end
  end
end
