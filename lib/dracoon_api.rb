# frozen_string_literal: true

require_relative "dracoon_api/version"
require "dotenv/load"
require "json"
require "rest-client"

module DracoonApi
  class Error < StandardError; end
  # Your code goes here...

  def self.auth_token
    response = RestClient.post basic_url + auth_endpoint,
                               {
                                 "login" => ENV["DRACOON_LOGIN"],
                                 "password" => ENV["DRACOON_PASSWORD"],
                                 "authType" => "sql"
                               }.to_json, { content_type: :json, accept: :json }
    @auth_token ||= JSON.parse(response)["token"]
  end

  # Dracoon-Endpoints
  def self.basic_url
    "https://mit-dataspace.lmu-klinikum.de/api/v4/"
  end

  def self.auth_endpoint
    "auth/login"
  end
end

puts DracoonApi.auth_token
