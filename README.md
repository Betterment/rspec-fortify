# RSpec::Fortify

RSpec::Fortify is a hard fork of [rspec-retry](https://github.com/NoRedInk/rspec-retry)

RSpec::Fortify adds a ``:retry`` option for intermittently failing rspec examples.
If an example has the ``:retry`` option, rspec will run the example the
specified number of times until the example succeeds.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-fortify', group: :test # Unlike rspec, this doesn't need to be included in development group
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-fortify

require in ``spec_helper.rb``

```ruby
# spec/spec_helper.rb
require 'rspec/fortify'

RSpec.configure do |config|
  # run retry only on features
  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end

  # callback to be run between retries
  config.retry_callback = proc do |ex|
    # run some additional clean up task - can be filtered by example metadata
    if ex.metadata[:js]
      Capybara.reset!
    end
  end
end
```

## Usage

```ruby
it 'should randomly succeed', :retry => 3 do
  expect(rand(2)).to eq(1)
end

it 'should succeed after a while', :retry => 3, :retry_wait => 10 do
  expect(command('service myservice status')).to eq('started')
end
# RSpec::Fortify: 2nd try ./spec/lib/random_spec.rb:49
# RSpec::Fortify: 3rd try ./spec/lib/random_spec.rb:49
```

### Calling `run_with_retry` programmatically

You can call `ex.run_with_retry(opts)` on an individual example.

## Configuration

- __:verbose_retry__(default: *false*) Print retry status
- __:display_try_failure_messages__ (default: *false*) If verbose retry is enabled, print what reason forced the retry
- __:default_retry_count__(default: *1*) If retry count is not set in an example, this value is used by default. Note that currently this is a 'try' count. If increased from the default of 1, all examples will be retried. We plan to fix this as a breaking change in version 1.0.
- __:default_sleep_interval__(default: *0*) Seconds to wait between retries
- __:clear_lets_on_failure__(default: *true*) Clear memoized values for ``let``s before retrying
- __:exceptions_to_hard_fail__(default: *[]*) List of exceptions that will trigger an immediate test failure without retry. Takes precedence over __:exceptions_to_retry__
- __:exceptions_to_retry__(default: *[]*) List of exceptions that will trigger a retry (when empty, all exceptions will)
- __:retry_callback__(default: *nil*) Callback function to be called between retries
- __:retry_on_failure__(default: *main? || pr?*) Retry examples on failure. This is useful for flaky tests that are not marked with `:retry` metadata.
- __:retry_on_failure_count__(default: *2*) Run examples on failure this many times.
- __:retry_on_success__(default: *pr? && changed_specs.size < 30*) Retry examples on success. This is useful in order to prove that new tests are not flaky.
- __:retry_on_success_count__(default: *10*) Run examples on success this many times.


## Environment Variables
- __RSPEC_FORTIFY_RETRY_COUNT__ can override the retry counts even if a retry count is set in an example or default_retry_count is set in a configuration.
- __CHANGED_SPECS__ can be set to a comma-separated list of spec files that have changed. This is used to determine if an example should be retried on success.
- __CI__ is used to determine if the current environment is a CI environment. This is used to determine if examples should be retried on success.
- __CIRCLE_PULL_REQUEST__ is used to determine if the current CI build is a pull request or a default branch build. This is used to determine if examples should be retried on success.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a pull request
