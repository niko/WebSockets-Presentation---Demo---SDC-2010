#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'em-websocket'

EventMachine.run do

  @sockets = []

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |socket|
    socket.onopen do
      @sockets << socket
      puts @sockets.inspect
    end

    socket.onmessage do |data|
      @sockets.each  do |s|
        puts "#{@sockets.index socket},#{data}"
        s.send "#{@sockets.index socket},#{data}"
      end
    end
  end # EM::WS

end # EM.run
