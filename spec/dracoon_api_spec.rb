# frozen_string_literal: true

require "./spec_helper"
require 'pry'

RSpec.describe DracoonApi do
  before(:all) do
    DracoonApi.login = ENV["DRACOON_LOGIN"]
    DracoonApi.password = ENV["DRACOON_PASSWORD"]
    DracoonApi.basic_url = ENV["BASIC_URL"]
    @expire_at = "3000-07-08T09:01:14.080Z"
  end

  before(:each) do
    @random_name = (0...8).map { rand(65..90).chr }.join
  end

  it "has a version number" do
    expect(DracoonApi::VERSION).not_to be nil
  end

  ## RB: regex auch nach Laenge, fuer die anderen auch
  it "outputs a valid auth token" do
    expect(DracoonApi.auth_token(DracoonApi.login, DracoonApi.password)).to match(/([A-Z])\w/)
  end

  it "makes successful POST requests" do
    # if successful, response is empty
    response = DracoonApi.basic_post_request("nodes/#{ENV["FILE_ID"]}/comments", {
                                               text: "string"

                                             })
    expect(response).to include("createdAt")
  end

  it "is able to download files" do
    response = DracoonApi.create_singular_file_download(
      ENV["FILE_ID"]
    )
    expect(response).to be_kind_of(RestClient::RawResponse)
  end

  it "is able to create download link" do
    response = DracoonApi.create_download_link(ENV["FILE_ID"],
                                               @expire_at)
    expect(response).to match(/([A-Z])\w/)
  end

  it "is able to create an upload link" do
    response = DracoonApi.create_upload_link(ENV["PARENT_ID"],
                                             @expire_at)
    expect(response).to match(/([A-Z])\w/)
  end

  it "is able to create a room" do
    test_group = [1]
    response = DracoonApi.create_room(@random_name,
                                      ENV["PARENT_ID"], test_group)
                                      ## Lesbarkeit verbessern, siehe RB Slack msg, s.u, auch fuer folder.
    expect(response).to include("\"type\" : \"room\"")
  end

  it "is able to create a folder" do
    response = DracoonApi.create_folder(@random_name,
                                        ENV["PARENT_ID"])
    expect(response).to include("\"type\" : \"folder\"")
  end

  it "is able to create a file" do
    file = DracoonApi.create_singular_file_download(
      ENV["FILE_ID"]
    )
    response = DracoonApi.create_file_on_dracoon(file, @random_name, ENV["PARENT_ID"], @expire_at)
    expect(response).to include("fileType")
  end

  it "is able to delete a node (room, folder or file)" do
    node_id_to_delete = JSON.parse(DracoonApi.create_folder(@random_name,
                                                            ENV["PARENT_ID"]))["id"]
    response = DracoonApi.delete_file(node_id_to_delete)
    expect(response).not_to include("errorCode")
  end

  it "is able to get list of nodes" do
    response = DracoonApi.all_nodes
    expect(response).to include("items")
  end

  it "is able to get a node (room, folder or file)" do
    DracoonApi.nodes_getter(ENV["PARENT_ID"])
  end

  ## mit pry reingehen, im Gemfile in dev dependencies
  it "is able to search nodes (room, folder or file)" do
   response = DracoonApi.nodes_query('personal')
   parsed_response = JSON.parse(response)
   expect(parsed_response).to include("items")
  end

  it "is able to get a list of user groups" do
    response = DracoonApi.groups
    expect(response).to include("items")
  end
  
  
end
