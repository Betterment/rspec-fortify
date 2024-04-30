# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Bad Test Example' do # rubocop:disable RSpec/FilePath
  let(:foo) { false }

  it 'is a bad test' do
    expect(foo).to eq true
  end
end
