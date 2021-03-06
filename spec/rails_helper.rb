require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'pry'

# Custom helper methods
require 'support/capybara_helpers'
require 'support/rspec_helpers'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

# Stub geocoder response
Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    { data:
      { 
      'lat' => 52,
      'lon' => 12,
      'house_number' => '19',
      'street' => 'Magdalenenstraße',
      'postcode' => '10365',
      'district' => 'Lichtenberg',
      'town' => 'Berlin',
      'state' => 'Berlin',
      'country' => 'Germany',
      'type' => 'house',
      'boundingbox' => [52.5, 52.3, 13.0, 12.5] }
  }
  ]
)

# CAPYBARA configuration
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    phantomjs_options: ['--ignore-ssl-errors=true'],
                                    js_errors: false,
                                    window_size: [1200, 1200],
                                    inspector: true)
end

Capybara.configure do |config|
  config.javascript_driver = :poltergeist
  config.current_driver = Capybara.javascript_driver
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:each) do
    create :settings
  end

  config.before(:suite) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, no_transaction: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    create :settings
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Capybara::DSL
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include RSpecHelpers
  config.include CapybaraHelpers
end
