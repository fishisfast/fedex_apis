# frozen_string_literal: true

module FedexApis
  module Resource
    class Token
      def initialize(attributes = {})
        @attributes = attributes
      end

      def method_missing(method_name, *args)
        if method_name.to_s.end_with?('=')
          @attributes[method_name.to_s.chomp('=').to_sym] = args.first
        elsif @attributes.key?(method_name.to_s)
          @attributes[method_name.to_s]
        elsif @attributes.key?(method_name)
          @attributes[method_name]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.end_with?('=') ||
          @attributes.key?(method_name.to_s) ||
          @attributes.key?(method_name) ||
          super
      end

      def to_h
        @attributes
      end
    end
  end
end
