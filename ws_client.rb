require 'rubygems'
require 'eventmachine'
require 'em-http'

EventMachine.run {
  http = EventMachine::HttpRequest.new("ws://localhost:8080/").get :timeout => 0

  http.errback  { |e| puts e }
  http.callback { puts "WebSocket connected!" }
  http.stream  { |msg| puts "Recieved: #{msg}" }

  t, radius, center = 0, 200, [400,400]
  EventMachine::PeriodicTimer.new(1) do
    x = (radius * Math.sin(t/10.0)).to_i + center[0]
    y = (radius * Math.cos(t/10.0)).to_i + center[1]

    http.send "#{x},#{y}" and puts "#{x},#{y}"
    t += 1
  end
}
