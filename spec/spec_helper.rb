# frozen_string_literal: true

require 'rspec/fortify'

module GitDiffChangedSpecsStub
  def git_diff_changed_specs
    "spec/fixtures/diff_test.rb\n"
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    RSpec::Fortify.singleton_class.prepend(GitDiffChangedSpecsStub)
  end
end
