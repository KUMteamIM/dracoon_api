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
                                               text: "string"

                                             })
    expect(response).to include("createdAt")
  end

  it "is able to download files" do
    response = DracoonApi.create_singular_file_download(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], ENV["FILE_ID"])
    expect(response).to be_kind_of(RestClient::RawResponse)
  end

  it "is able to create download link" do
    # expire in year 3000
    response = DracoonApi.create_download_link(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], ENV["FILE_ID"],
                                               "3000-07-08T09:01:14.080Z")
    expect(response).to match(/([A-Z])\w/)
  end

  it "is able to create an upload link" do
    # expire in year 3000
    response = DracoonApi.create_upload_link(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], ENV["PARENT_ID"],
                                             "3000-07-08T09:01:14.080Z")
    expect(response).to match(/([A-Z])\w/)
  end
end
