require 'rubygems'
require 'eventmachine'
require 'em-http'

EventMachine.run {
  http = EventMachine::HttpRequest.new("ws://localhost:8080/").get :timeout => 0

  http.callback { puts "WebSocket connected!" }
  http.stream   { |msg| puts "Recieved: #{msg}" }

  t, radius, center = 0.0, 300, {:x => 310, :y => 330}
  EventMachine::PeriodicTimer.new(0.1) do
    x = (radius * Math.cos(t/10)).to_i + center[:x]
    y = (radius * Math.sin(t/10)).to_i + center[:y]

    t +=1 and http.send "#{x},#{y}" and puts "#{x},#{y}"
  end
}
