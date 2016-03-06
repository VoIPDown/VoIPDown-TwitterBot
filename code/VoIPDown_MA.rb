#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'
require 'date'
require 'yaml'

block_date   = Date.new(2016,1,5)
days_blocked = (Date.today - block_date).to_i

tweets = [
  "Hey #USER#! did you know that VoIP was blocked by ANRT (host of #ICANN55) #{days_blocked} days ago? Learn more at http://voipdown.com #VoIPDown",
  "#USER#, did you know that ALL VoIP comm were banned by ANRT (host of #ICANN55) #{days_blocked} days ago? Learn more at http://voipdown.com",
  "Hi #USER#! #{days_blocked} days ago ANRT (host of #ICANN55) banned all VoIP comm in Morocco. Learn more at http://voipdown.com #VoIPDown",
  "Hey #USER#! #{days_blocked} days ago ANRT (host of #ICANN55) blocked all VoIP comm in Morocco. Learn more at http://voipdown.com #VoIPDown",
  "Hi #USER#! #{days_blocked} days ago ANRT, host of #ICANN55, banned VoIP in Morocco like... North Corea did ... #VoIPDown",
  "Hey #USER#! #{days_blocked} days ago ANRT, host of #ICANN55, banned VoIP in Morocco like... Pakistan did ... #VoIPDown",
  "Hi #USER#! #{days_blocked} days ago ANRT, host of #ICANN55, banned Whatsapp calls and said it needs a licence! #VoIPDown",
  "Hey #USER#! #{days_blocked} days ago ANRT, host of #ICANN55, banned Whatsapp calls and said it needs a licence! #VoIPDown",
  "Hi #USER#! #{days_blocked} days ago ANRT, host of #ICANN55, banned Facetime and said it needs a licence! #VoIPDown",
  "Hey #USER#! #{days_blocked} days ago ANRT, host of #ICANN55, decided to illegally to bann VoIP in Morocco?",
  "Did you know #USER# that, ANRT, host of #ICANN55, proposed to use @Skype for #ICANN55 but banned it for 35M Moroccans...?",
  "Did you know #USER# that ANRT, host of #ICANN55, banned Whatsapp, Facetime and Skype in #Morocco?"
]

twitter_search_string = "#icann55 OR icann55"

# Remove this to send out tweets.
# debug_mode

# Remove this to update the db.
# no_update

# Remove this to get less output when running.
verbose

# List of users to ignore
blacklist "WALOU"

# Exclude from search.
exclude "spammer", "junk", "RT"

def is_new_user(user)
  users = YAML.load_file('users.yml')
  exists = users.include?(user)

  if !exists
    puts "User #{user} is new. Pushing to YAML before sending tweet..."
    users.push(user)

    File.open("users.yml", 'w') { |f| YAML.dump(users, f) }
  end

  return exists
end

begin
  loop do
    search twitter_search_string do |tweet|
      # Check if user hasn't already been contacted.
      reply(tweets.sample, tweet) if is_new_user(tweet_user(tweet))
      # follow tweet.user
      sleep rand(300..1800)
    end

    # Explicitly update our config.
    update_config

    sleep rand(300..1800)
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