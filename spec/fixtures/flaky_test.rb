# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Flaky Test Example' do # rubocop:disable RSpec/FilePath
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    $try_counter = 0 # rubocop:disable Style/GlobalVars
  end

  it 'fails on the third try' do
    $try_counter += 1 # rubocop:disable Style/GlobalVars

    expect($try_counter).not_to eq(3), 'Intentionally failing on the third try' # rubocop:disable Style/GlobalVars
  end
end
