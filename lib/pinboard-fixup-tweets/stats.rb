# frozen_string_literal: true
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

    def initialize
      @counters = Hash.new { |stats, name| stats[name] = Counter.new(name) }
      @gauges = Hash.new { |stats, name| stats[name] = Gauge.new(name) }
    end

    def increment(name)
      @counters[name].increment
    end

    def counter(name)
      @counters[name].value
    end

    def gauge(name, value = nil)
      if value
        @gauges[name].update(value)
      else
        @gauges[name].value
      end
    end

    def to_s
      (@counters.values + @gauges.values).sort_by(&:name).join(', ')
    end
  end
end
