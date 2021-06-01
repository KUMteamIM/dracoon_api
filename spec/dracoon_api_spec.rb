# frozen_string_literal: true

require "./spec_helper"

RSpec.describe DracoonApi do
  it "has a version number" do
    expect(DracoonApi::VERSION).not_to be nil
  end

  it " def auth_token delivers a valid auth token" do
    expect(DracoonApi.auth_token).to match(/([A-Z])\w/)
  end
end
