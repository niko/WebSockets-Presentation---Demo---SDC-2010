#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'em-websocket'

EventMachine.run do

  @clients = []

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8081) do |ws|
    ws.onopen do
      @clients << ws
      puts @clients.inspect
    end

    ws.onmessage do |msg|
      @clients.each { |s| s.send "#{@clients.index ws},#{msg}" }
      print '.' * @clients.size
      STDOUT.flush
    end

    ws.onclose do
      @clients.delete ws
      puts @clients.inspect
    end
  end # EM::WS

end # EM.run
