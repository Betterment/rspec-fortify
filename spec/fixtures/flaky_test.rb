require 'spec_helper'

RSpec.describe 'Flaky Test Example' do
  before(:all) do
    $try_counter = 0
  end

  it 'fails on the third try' do
    $try_counter += 1

    expect($try_counter).not_to eq(3), "Intentionally failing on the third try"
  end
end
