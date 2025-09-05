# frozen_string_literal: true

require_relative "lib/ecpay/version"

Gem::Specification.new do |spec|
  spec.name = "ecpay_b2c_invoice"
  spec.version = Ecpay::VERSION
  spec.authors = ["Leo Chen"]
  spec.email = ["Leo@Heartron.ai"]

  spec.summary = "ECPay B2C Electronic Invoice API Client"
  spec.description = "Ruby client library for ECPay B2C electronic invoice API integration"
  spec.homepage = "https://github.com/Heart301/ecpay_b2c_invoice"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Heart301/ecpay_b2c_invoice"
  spec.metadata["changelog_uri"] = "https://github.com/Heart301/ecpay_b2c_invoice/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.21"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
