# frozen_string_literal: true

require "bundler/setup"
require "ecpay_b2c_invoice"
require "webmock/rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  config.before(:each) do
    Ecpay::B2CInvoice.configuration = Ecpay::B2CInvoice::Configuration.new
  end
end