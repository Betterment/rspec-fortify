require 'spec_helper'

RSpec.describe 'Bad Test Example' do
  let(:foo) { false }

  it 'is a bad test' do
    expect(foo).to eq true
  end
end
