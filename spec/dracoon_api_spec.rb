# frozen_string_literal: true

require "./spec_helper"

RSpec.describe DracoonApi do
  it "has a version number" do
    expect(DracoonApi::VERSION).not_to be nil
  end

  it "def auth_token delivers, with valid input, delivers a valid auth token" do
    expect(DracoonApi.auth_token(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"])).to match(/([A-Z])\w/)
  end

  it "basic_get_request, with valid login, endpoint and no options, returns valid output" do
    expect(DracoonApi.basic_get_request(ENV["DRACOON_LOGIN"], ENV["DRACOON_PASSWORD"], "nodes")).to be_truthy
  end
end
