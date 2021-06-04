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
    expect(DracoonApi.basic_post_request(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], "auth/reset_password", {
                                           userName: ENV["DRACOON_LOGIN"]
                                         })).to match("")
  end

  it "is able to download files" do
    response =  DracoonApi.create_singular_file_download(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], 1089)
    expect(response).to be_kind_of(RestClient::RawResponse)
  end

  it "is able to create download link" do
    
  end
  
end
