# frozen_string_literal: true

require 'rspec/fortify'

# Need to store the original method by capturing it from the current context
$original_git_diff_changed_specs_method = method(:git_diff_changed_specs) # rubocop:disable Style/GlobalVars

def git_diff_changed_specs
  if ENV['STUB_GIT_DIFF'] == 'true'
    "spec/fixtures/good_test.rb\n"
  else
    # Call the original method
    $original_git_diff_changed_specs_method.call # rubocop:disable Style/GlobalVars
  end
end
