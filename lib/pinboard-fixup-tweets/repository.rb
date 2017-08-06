# frozen_string_literal: true
require 'twitter'

module PinboardFixupTweets
  class Repository
    def tweet(id)
      twitter.status(id)
    end

    def twitter
      @twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV.fetch('TWITTER_CONSUMER_KEY')
        config.consumer_secret     = ENV.fetch('TWITTER_CONSUMER_SECRET')
      end
    end
  end
end
