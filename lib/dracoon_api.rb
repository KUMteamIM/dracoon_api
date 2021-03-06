# frozen_string_literal: true

require_relative "dracoon_api/version"
require "dotenv/load"
require "json"
require "rest-client"

# API documentation: https://dracoon.team/api/swagger-ui/index.html?configUrl=/api/spec_v4/swagger-config#/
# set login, password and your basic_url (your individual Dracoon URL) using dotenv
# see https://github.com/bkeepers/dotenv
# DracoonApi.login = ENV[YOUR LOGIN]
# DracoonApi.password = ENV[YOUR PASSWORD]
# DracoonApi.basic_url = ENV[YOUR BASIC_URL]

module DracoonApi
  # getter and setter for login and password
  ## Go through with Rouven again
  class << self
    attr_accessor :login, :password, :basic_url
  end

  def self.basic_get_request(endpoint, options = {})
    url = "#{basic_url}#{endpoint}?#{URI.encode_www_form(options)}"
    response = RestClient.get url,
                              { :accept => :json,
                                "X-Sds-Auth-Token" => auth_token }
    JSON.parse(response)
  end

  def self.basic_post_request(endpoint, options = {})
    RestClient.post "#{basic_url}#{endpoint}", options.to_json,
                    { content_type: :json, accept: :json, "X-Sds-Auth-Token" => auth_token }
  end

  def self.create_singular_file_download(file_id)
    download_url = JSON.parse(
      RestClient::Request.execute(
        method: :post,
        url: "#{basic_url}#{file_download_endpoint(file_id)}",
        headers: { "X-Sds-Auth-Token" => auth_token }
      )
    )["downloadUrl"]
    RestClient::Request.execute(
      method: :get,
      url: download_url,
      headers: { "X-Sds-Auth-Token" => auth_token },
      raw_response: true
    )
  end

  def self.create_download_link(parent_id, expiration_date = "")
    options = { nodeId: parent_id, password: password }.merge(expiration: expiration(expiration_date))

    JSON.parse(basic_post_request(share_download_endpoint, options))["accessKey"]
  end

  def self.create_upload_link(parent_id, expiration_date = "")
    options = { targetId: parent_id }.merge(expiration: expiration(expiration_date))
    JSON.parse(basic_post_request(share_upload_endpoint, options))["accessKey"]
  end

  def self.create_room(name, parent_id, permissioned_groups = [])
    options = {
      name: name,
      parentId: parent_id,
      adminGroupIds: permissioned_groups
    }
    basic_post_request(rooms_endpoint, options)
  end

  def self.create_folder(name, parent_id)
    options = { name: name, parentId: parent_id }
    basic_post_request(folders_endpoint, options)
  end

  def self.expiration(expiration_date)
    if expiration_date
      { enableExpiration: true, expireAt: expiration_date.to_s }
    else
      { enableExpiration: false }
    end
  end

  def self.create_file_on_dracoon(file, file_name, folder_id, expiration_date)
    puts "Requesting Upload-Channel for file #{file_name}"
    options = { name: file_name, parentId: folder_id }.merge(expiration: expiration(expiration_date))
    open_channel_request = basic_post_request(upload_channel_endpoint, options)
    upload_url = JSON.parse(open_channel_request)["uploadUrl"]
    puts "Uploading file #{file_name}"
    RestClient.post upload_url, file: file
    puts "Closing Channel for file #{file_name}"
    RestClient.put upload_url, {}.to_json, { content_type: :json, accept: :json }
  end

  def self.delete_file(file_id)
    RestClient.delete "#{basic_url}#{nodes_endpoint}/#{file_id}",
                      { content_type: :json, accept: :json,
                        "X-Sds-Auth-Token" => auth_token }
  end

  # query and getter helper methods

  def self.all_nodes
    basic_get_request(nodes_endpoint)
  end

  def self.nodes_getter(parent_id)
    basic_get_request(nodes_endpoint, { parent_id: parent_id })
  end

  def self.nodes_query(query)
    basic_get_request(nodes_search_endpoint, { search_string: query, depth_level: -1 })
  end

  def self.groups
    basic_get_request(groups_endpoint)
  end

  # Dracoon-Endpoints

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
    "nodes"
  end

  def self.nodes_search_endpoint
    "#{nodes_endpoint}/search"
  end

  def self.groups_endpoint
    "groups"
  end

  def self.auth_token
    response = RestClient.post basic_url + auth_endpoint,
                               {
                                 "login" => DracoonApi.login,
                                 "password" => DracoonApi.password,
                                 "authType" => "sql"
                               }.to_json, { content_type: :json, accept: :json }
    @auth_token ||= JSON.parse(response)["token"]
  end
end
