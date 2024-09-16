# frozen_string_literal: true

module Plunk
  module ActionMailer
    class DeliveryMethod
      attr_accessor :settings

      ALLOWED_PARAMS = %i[api_key api_host].freeze

      def initialize(settings)
        self.settings = settings
      end

      def deliver!(message)
        mail = Plunk::Mail.from_message(message)

        client.send(mail)
      end

      private

      def client
        @client ||= Plunk::Client.new(**settings.slice(*ALLOWED_PARAMS))
      end
    end
  end
end
