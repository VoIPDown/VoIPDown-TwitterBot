#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'
require 'date'

block_date   = Date.new(2016,1,5)
days_blocked = (Date.today - block_date).to_i

consumer_key    ENV['VOIPDOWN_TWITTER_CONSUMER_KEY']
consumer_secret ENV['VOIPDOWN_TWITTER_CONSUMER_SECRET']
secret          ENV['VOIPDOWN_TWITTER_SECRET']
token           ENV['VOIPDOWN_TWITTER_TOKEN']

tweets = [
  "Hey #USER#! did you know that VoIP was blocked by ANRT (host of #ICANN55) #{days_blocked} days ago? Learn more at http://voipdown.com #VoIPDown",
  "#USER#, did you know that ALL VoIP comm were banned by ANRT (host of #ICANN55) #{days_blocked} days ago? Learn more at http://voipdown.com",
  "Hi #USER#! #{days_blocked} days ago ANRT (host of #ICANN55) banned all VoIP comm in Morocco. Learn more at http://voipdown.com #VoIPDown",
  "Hi #USER#! #{days_blocked} days ago ANRT (host of #ICANN55) blocked all VoIP comm in Morocco. Learn more at http://voipdown.com #VoIPDown"
]

twitter_search_string = "icann OR icann55 OR #icann55 OR isoc OR anrt"

# Remove this to send out tweets.
debug_mode

# Remove this to update the db.
# no_update

# Remove this to get less output when running.
verbose

# List of users to ignore
blacklist "WALOU"

# Exclude from search.
exclude "spammer", "junk"

begin
  loop do
    search twitter_search_string do |tweet|
      reply tweets.sample, tweet
      follow tweet.user
    end

    # Explicitly update our config.
    update_config

    sleep 60
  end
rescue Twitter::Error::TooManyRequests => error
  puts "Rate limit exceeded: #{error}, sleeping for #{error.rate_limit.reset_in}"
  sleep error.rate_limit.reset_in
  retry
rescue
  puts "Something went wrong. Retrying. #{$!}"
  sleep 3
  retry
end