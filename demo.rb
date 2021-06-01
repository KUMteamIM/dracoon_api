# frozen_string_literal: true

require_relative "lib/dracoon_api"

DracoonApi.config do |c|
  c.login = "foo"
  c.password = "bar"

  puts DracoonApi.login
  puts DracoonApi.password
end
