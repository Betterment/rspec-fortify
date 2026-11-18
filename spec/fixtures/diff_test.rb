# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Diff Test Example' do
  let(:foo) { true }

  it 'is a diff test' do
    expect(foo).to eq true
  end
end
