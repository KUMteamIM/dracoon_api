# frozen_string_literal: true

require_relative "dracoon_api/version"
require "dotenv/load"
require "json"
require "rest-client"

# API documentation: https://mit-dataspace.lmu-klinikum.de/api
module DracoonApi
  class << self
    attr_accessor :login, :password

    def config
      yield self
    end
  end

  class Error < StandardError; end

  def self.auth_token(login, password)
    response = RestClient.post basic_url + auth_endpoint,
                               {
                                 "login" => login,
                                 "password" => password,
                                 "authType" => "sql"
                               }.to_json, { content_type: :json, accept: :json }
    @auth_token ||= JSON.parse(response)["token"]
  end

  def self.basic_get_request(login, password, endpoint, options = {})
    response = RestClient.get "#{basic_url}#{endpoint}?#{options}",
                              { :accept => :json, "X-Sds-Auth-Token" => auth_token(login, password) }
    JSON.parse(response)
  end

  # Dracoon-Endpoints
  def self.basic_url
    "https://mit-dataspace.lmu-klinikum.de/api/v4/"
  end

  def self.auth_endpoint
    "auth/login"
  end
end
