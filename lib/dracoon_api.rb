# frozen_string_literal: true

require_relative "dracoon_api/version"
require "dotenv/load"
require "json"
require "rest-client"

# API documentation: https://dracoon.team/api/swagger-ui/index.html?configUrl=/api/spec_v4/swagger-config#/
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

  def self.basic_post_request(login, password, endpoint, options = {})
    RestClient.post "#{basic_url}#{endpoint}", options.to_json,
                    { content_type: :json, accept: :json, "X-Sds-Auth-Token" => auth_token(login, password) }
  end

  def self.create_singular_file_download(login, password, file_id)
    download_url = JSON.parse(
      RestClient::Request.execute(
        method: :post,
        url: "#{basic_url}#{file_download_endpoint(file_id)}",
        headers: { "X-Sds-Auth-Token" => auth_token(login, password) }
      )
    )["downloadUrl"]
    RestClient::Request.execute(
      method: :get,
      url: download_url,
      headers: { "X-Sds-Auth-Token" => auth_token(login, password) },
      raw_response: true
    )
  end

  def self.create_download_link(parent_id, expiration_date = '', password= '')
    options = { nodeId: parent_id, password: password}.merge(expiration: expiration(expiration_date))

    JSON.parse(basic_post_request(share_download_endpoint, options))['accessKey']
  end

  # Dracoon-Endpoints
  def self.basic_url
    ENV["BASIC_URL"]
  end

  def self.auth_endpoint
    "auth/login"
  end

  def self.file_download_endpoint(file_id)
    "nodes/files/#{file_id}/downloads"
  end

  def share_download_endpoint
    'shares/downloads'
  end
end

# puts DracoonApi.auth_token(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"])

