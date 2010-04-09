require 'rubygems'
require 'eventmachine'
require 'em-http'

EventMachine.run {
  ws = EventMachine::HttpRequest.new("ws://localhost:8081/").get :timeout => 0

  ws.callback { puts "WebSocket connected!" }
  ws.stream   { |msg| puts "Recieved: #{msg}" }

  t, radius, center = 0.0, 300, {:x => 310, :y => 330}
  EventMachine::PeriodicTimer.new(0.1) do
    x = (radius * Math.cos(t/10)).to_i + center[:x]
    y = (radius * Math.sin(t/10)).to_i + center[:y]

    ws.send "#{x},#{y}"
    puts "#{x},#{y}"
    t +=1
  end
}
