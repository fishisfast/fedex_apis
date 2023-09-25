# frozen_string_literal: true

require_relative "lib/fedex_apis/version"

Gem::Specification.new do |spec|
  spec.name = "fedex_apis"
  spec.version = FedexApis::VERSION
  spec.authors = ["Fishisfast Team"]
  spec.email = ["dev@fishisfast.com"]

  spec.summary = "Fedex RESTful API wrapper."
  spec.description = "Fedex RESTful API wrapper."
  spec.homepage = "https://github.com/fishisfast/fedex_apis"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fishisfast/fedex_apis"
  spec.metadata["changelog_uri"] = "https://github.com/fishisfast/fedex_apis/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "excon"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
