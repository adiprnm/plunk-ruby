# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Plunk
  class Client
    SENDING_API_HOST = 'api.useplunk.com'
    API_PORT = 443

    attr_reader :api_key, :api_host, :api_port

    # Initializes a new Plunk::Client instance.
    #
    # @param [String] api_key The Plunk API key to use for sending. Required.
    #                         If not set, is taken from the MAILTRAP_API_KEY environment variable.
    # @param [String, nil] api_host The Plunk API hostname. If not set, is chosen internally.
    # @param [Integer] api_port The Plunk API port. Default: 443.
    # @param [Boolean] bulk Whether to use the Plunk bulk sending API. Default: false.
    #                       If enabled, is incompatible with `sandbox: true`.
    # @param [Boolean] sandbox Whether to use the Plunk sandbox API. Default: false.
    #                          If enabled, is incompatible with `bulk: true`.
    # @param [Integer] inbox_id The sandbox inbox ID to send to. Required if sandbox API is used.
    def initialize( # rubocop:disable Metrics/ParameterLists
      api_key: ENV.fetch('PLUNK_API_KEY'),
      api_host: nil,
      api_port: API_PORT
    )
      raise ArgumentError, 'api_key is required' if api_key.nil?
      raise ArgumentError, 'api_port is required' if api_port.nil?

      @api_key = api_key
      @api_host = api_host || api_host()
      @api_port = api_port
    end

    def send(mail)
      raise ArgumentError, 'should be Plunk::Mail::Base object' unless mail.is_a? Mail::Base

      request = post_request(request_url, mail.to_json)
      response = http_client.request(request)
      pp response

      handle_response(response)
    end

    private

    def api_host
      SENDING_API_HOST
    end

    def request_url
      "/v1/send"
    end

    def http_client
      @http_client ||= Net::HTTP.new(api_host, api_port).tap { |client| client.use_ssl = true }
    end

    def post_request(path, body)
      request = Net::HTTP::Post.new(path)
      request.body = body
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = 'plunk-ruby (https://github.com/adiprnm/plunk-ruby)'

      request
    end

    def handle_response(response) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      case response
      when Net::HTTPOK
        json_response(response.body)
      when Net::HTTPBadRequest
        raise Plunk::Error, json_response(response.body)[:errors]
      when Net::HTTPUnauthorized
        raise Plunk::AuthorizationError, json_response(response.body)[:errors]
      when Net::HTTPForbidden
        raise Plunk::RejectionError, json_response(response.body)[:errors]
      when Net::HTTPPayloadTooLarge
        raise Plunk::MailSizeError, ['message too large']
      when Net::HTTPTooManyRequests
        raise Plunk::RateLimitError, ['too many requests']
      when Net::HTTPClientError
        raise Plunk::Error, ['client error']
      when Net::HTTPServerError
        raise Plunk::Error, ['server error']
      else
        raise Plunk::Error, ["unexpected status code=#{response.code}"]
      end
    end

    def json_response(body)
      JSON.parse(body, symbolize_names: true)
    end
  end
end
