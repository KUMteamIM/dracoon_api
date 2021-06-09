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

  def self.create_download_link(login, password, parent_id, expiration_date = "")
    options = { nodeId: parent_id, password: password }.merge(expiration: expiration(expiration_date))

    JSON.parse(basic_post_request(login, password, share_download_endpoint, options))["accessKey"]
  end

  def self.create_upload_link(login, password, parent_id, expiration_date = "")
    options = { targetId: parent_id }.merge(expiration: expiration(expiration_date))
    JSON.parse(basic_post_request(login, password, share_upload_endpoint, options))["accessKey"]
  end

  def self.create_room(login, password, name, parent_id, permissioned_groups = [])
    options = {
      name: name,
      parentId: parent_id,
      adminGroupIds: permissioned_groups
    }
    basic_post_request(login, password, rooms_endpoint, options)
  end

  def self.create_folder(login, password, name, parent_id)
    options = { name: name, parentId: parent_id }
    basic_post_request(login, password, folders_endpoint, options)
  end

  def self.expiration(expiration_date)
    if expiration_date
      { enableExpiration: true, expireAt: expiration_date.to_s }
    else
      { enableExpiration: false }
    end
  end

  def self.create_file_on_dracoon(login, password, file, file_name, folder_id, expiration_date)
    puts "Requesting Upload-Channel for file #{file_name}"
    options = { name: file_name, parentId: folder_id }.merge(expiration: expiration(expiration_date))
    open_channel_request = basic_post_request(login, password, upload_channel_endpoint, options)
    upload_url = JSON.parse(open_channel_request)["uploadUrl"]
    puts "Uploading file #{file_name}"
    RestClient.post upload_url, file: file
    puts "Closing Channel for file #{file_name}"
    RestClient.put upload_url, {}.to_json, { content_type: :json, accept: :json }
  end

  def self.delete_file(login, password, file_id)
    RestClient.delete "#{basic_url}#{nodes_endpoint}/#{file_id}",
                      { content_type: :json, accept: :json, 'X-Sds-Auth-Token' => auth_token(login, password) }
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

  def self.share_download_endpoint
    "shares/downloads"
  end

  def self.share_upload_endpoint
    "shares/uploads"
  end

  def self.rooms_endpoint
    "nodes/rooms"
  end

  def self.folders_endpoint
    "nodes/folders"
  end

  def self.upload_channel_endpoint
    # init file upload and select room or folder id
    "nodes/files/uploads"
  end

  def self.nodes_endpoint
    'nodes'
  end
end
