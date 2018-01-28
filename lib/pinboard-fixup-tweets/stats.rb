# frozen_string_literal: true
require 'time'

module PinboardFixupTweets
  class Stats
    class Tracked
      attr_reader :name, :value

      def initialize(name)
        @name = name
        @value = 0
      end

      def to_s
        "#{@name}: #{@value}"
      end

      def to_json(*_args)
        JSON.generate(@name => @value)
      end

      protected

      attr_writer :value
    end

    class Counter < Tracked
      #
      # Returns the previous value
      #
      def increment
        old_value = value
        self.value = value.next
        old_value
      end
    end

    class Gauge < Tracked
      #
      # Returns the previous value
      #
      def update(new_value)
        old_value = value
        self.value = new_value
        old_value
      end
    end

    def initialize(title = '')
      @title = title
      @created_at = Time.now
      @counters = Hash.new { |stats, name| stats[name] = Counter.new(name) }
      @gauges = Hash.new { |stats, name| stats[name] = Gauge.new(name) }
    end

    def increment(name)
      @counters[name.to_s].increment
    end

    def counter(name)
      @counters[name.to_s].value
    end

    def gauge(name, value = nil)
      if value
        @gauges[name.to_s].update(value)
      else
        @gauges[name.to_s].value
      end
    end

    def to_json
      finished_at = Time.now

      {
        title: @title,
        created_at: @created_at.iso8601,
        finished_at: finished_at.iso8601,
        elapsed_time_in_seconds: finished_at - @created_at,
        counters: @counters.values,
        gauges: @gauges.values
      }.to_json
    end

    def to_s
      all = @counters.values + @gauges.values
      if all.empty?
        "#{@title}: No data was recorded."
      else
        @title << ': ' << all.sort_by(&:name).join(', ')
      end
    end
  end
end
