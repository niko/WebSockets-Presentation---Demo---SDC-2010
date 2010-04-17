require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'twitter/json_stream'
require 'ostruct'
require 'action_view'
require 'action_view/helpers'
require 'active_support'
require 'yajl'
require 'htmlentities'

module HTML
  extend self
  def ec(text)
    @encoder ||= HTMLEntities.new
    @encoder.encode text, :hexadecimal
  end
end

SEARCH = ['music', 'eat', 'drink']

class Tweet < OpenStruct
  include ActionView::Helpers

  def initialize(json)
    attrs = Yajl::Parser.parse(json)
    super attrs if attrs.is_a? Hash
  end

  def user_name
    user["name"]
  end

  def text_as_html
    auto_link(HTML.ec text).gsub(/(#{SEARCH.join('|')})/i, "<b>\\1</b>")
  end

  def to_s
    "#{user_name} (#{created_at}): #{text}"
  end

  def img_as_html
    %Q{<img src="#{ user['profile_image_url'] }">}
  end

  def to_html
    %Q{#{img_as_html}#{HTML.ec user_name} (#{created_at}): #{text_as_html}}
  end
end

@sockets = []
EM.kqueue = true
EventMachine.run do
  @twitter_stream = Twitter::JSONStream.connect(
    :path    => '/1/statuses/filter.json',
    :auth    => File.open(File.join(File.dirname(__FILE__), '.twitter_auth')).read.chomp,
    :method  => 'POST',
    :content => "track=#{SEARCH.join(',')}"
  )

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |socket|
    socket.onopen do
      @sockets << @socket = socket
    end
    socket.onclose do
      @sockets.delete @socket
    end
  end # EM::WS

  @twitter_stream.each_item do |item|
    tweet = Tweet.new(item)
    puts tweet.to_s
    STDOUT.flush
    @sockets.each do |ws|
      ws.send tweet.to_html
    end
  end

end # EM.run
