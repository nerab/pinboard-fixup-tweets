# frozen_string_literal: true

require 'spec_helper'
require 'pinboard-fixup-tweets/stats'
require 'timecop'

# rubocop:disable Metrics/BlockLength
RSpec.describe PinboardFixupTweets::Stats do
  subject do
    Timecop.freeze(Time.utc(2018, 1, 29, 21, 47, 11)) do
      described_class.new('Unit Test')
    end
  end

  # rubocop:disable Lint/ConstantDefinitionInBlock
  module Outer
    module Inner
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  it 'provides a summary telling that there is no data' do
    expect(subject.to_s).to eq('Unit Test: No data was recorded.')
  end

  context 'incrementing a counter with a symbol as name' do
    before do
      subject.increment(:foo)
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('Unit Test: foo: 1')
    end
  end

  context 'incrementing a counter with a string as name' do
    before do
      subject.increment('bar')
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('Unit Test: bar: 1')
    end
  end

  context 'incrementing a counter with a class as name' do
    before do
      subject.increment(Outer::Inner)
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('Unit Test: Outer::Inner: 1')
    end
  end

  context 'incrementing a counter with mixed names' do
    before do
      2.times { subject.increment(:bar) }
      3.times { subject.increment('foo') }
      4.times { subject.increment(Outer::Inner) }
      subject.gauge('hits', 69)
    end

    it 'provides a string summary' do
      expect(subject.to_s).to eq('Unit Test: Outer::Inner: 4, bar: 2, foo: 3, hits: 69')
    end

    context 'in JSON format' do
      let(:json) do
        Timecop.freeze(Time.utc(2018, 1, 29, 21, 54, 42)) do
          subject.to_json
        end
      end

      let(:parsed_json) { JSON.parse(json) }

      it 'is valid JSON' do
        expect(parsed_json).to be
      end

      context 'meta data' do
        let(:meta) { parsed_json['meta'] }
        it 'provides the stats title' do
          expect(meta['title']).to eq('Unit Test')
        end

        it 'has the correct created_at date' do
          expect(meta['created_at']).to eq('2018-01-29T21:47:11Z')
        end

        it 'has the correct elapsed_time_in_seconds' do
          expect(meta['elapsed_time_in_seconds']).to eq(451)
        end

        it 'has the correct finished_at date' do
          expect(meta['finished_at']).to eq('2018-01-29T21:54:42Z')
        end
      end

      it 'has all values' do
        expect(parsed_json['values']).to include('bar' => 2)
        expect(parsed_json['values']).to include('foo' => 3)
        expect(parsed_json['values']).to include('Outer::Inner' => 4)
        expect(parsed_json['values']).to include('hits' => 69)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
