# frozen_string_literal: true

require_relative "lib/dracoon_api/version"

Gem::Specification.new do |spec|
  spec.name          = "dracoon_api"
  spec.version       = DracoonApi::VERSION
  spec.authors       = ["Pradeep Jerome"]
  spec.email         = ["prjerome@gmail.com"]

  spec.summary       = "Access the Dracoon API using Ruby."
  spec.homepage      = "https://github.com/KUMteamIM/dracoon_api."
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/KUMteamIM/dracoon_api."
  spec.metadata["changelog_uri"] = "https://github.com/KUMteamIM/dracoon_api/blob/main/CHANGELOG.md."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency 'json', '~> 2.5', '>= 2.5.1'
  spec.add_development_dependency 'rest-client', '~> 1.8'
  spec.add_development_dependency 'dotenv', '~> 2.1', '>= 2.1.1'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
