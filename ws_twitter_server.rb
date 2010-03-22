#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'em-websocket'

require 'active_support'
require 'yajl'

lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
 
require 'twitter/json_stream'

EventMachine.run do

  @twitter_stream = Twitter::JSONStream.connect(
    :path    => '/1/statuses/filter.json',
    :auth    => File.open('ws_demo/.twitter_auth').read.chomp,
    :method  => 'POST',
    :content => 'track=music'
  )

  @sockets = []

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |socket|
    socket.onopen do
      @sockets << @socket = socket
    end
    socket.onclose do
      @sockets.delete @socket
    end

    @twitter_stream.each_item do |item|
      @sockets.each do |ws|
        msg = Yajl::Parser.parse(item)
        name = msg["user"]["name"]
        time = Time.parse(msg["created_at"]).to_s(:long)
        msg = msg["text"].gsub(/(music)/i, "<b>\\1</b>")
        puts msg

        ws.send %Q{#{name} (#{time}): #{msg}\n}
      end
    end
  end # EM::WS

end # EM.run
