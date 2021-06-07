# frozen_string_literal: true

require "./spec_helper"

RSpec.describe DracoonApi do
  it "has a version number" do
    expect(DracoonApi::VERSION).not_to be nil
  end

  it "outputs a valid auth token" do
    expect(DracoonApi.auth_token(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"])).to match(/([A-Z])\w/)
  end

  it "gets successful responses to GET requests" do
    response = DracoonApi.basic_get_request(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], "nodes")
    expect(response).to include("items")
  end

  it "gets successful responses to POSTS requests" do
    # if successful, response is empty
    response = DracoonApi.basic_post_request(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], "nodes/#{ENV["FILE_ID"]}/comments", {
        "text": "string"
      
    })
    expect(response).to include("createdAt")
  end

  it "is able to download files" do
    response =  DracoonApi.create_singular_file_download(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], ENV["FILE_ID"])
    expect(response).to be_kind_of(RestClient::RawResponse)
  end

  it "is able to create download link" do
    expire_at = DateTime.now
    response = DracoonApi.create_download_link(ENV["PARENT_ID"], expire_at, ENV["DRACOON_PASSWORD"])
    expect(response).to be_truthy
  end
  
end
