# frozen_string_literal: true

require 'spec_helper'
require 'pinboard-fixup-tweets/stats'

# rubocop:disable Metrics/BlockLength
RSpec.describe PinboardFixupTweets::Stats do
  module Outer
    module Inner
    end
  end

  it 'provides a summary telling that there is no data' do
    expect(subject.to_s).to eq('No data was recorded.')
  end

  context 'incrementing a counter with a symbol as name' do
    before do
      subject.increment(:foo)
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('foo: 1')
    end
  end

  context 'incrementing a counter with a string as name' do
    before do
      subject.increment('bar')
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('bar: 1')
    end
  end

  context 'incrementing a counter with a class as name' do
    before do
      subject.increment(Outer::Inner)
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('Outer::Inner: 1')
    end
  end

  context 'incrementing a counter with mixed names' do
    before do
      2.times { subject.increment(:bar) }
      3.times { subject.increment('foo') }
      4.times { subject.increment(Outer::Inner) }
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('Outer::Inner: 4, bar: 2, foo: 3')
    end
  end
end
