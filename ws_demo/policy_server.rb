require 'rubygems'
require 'eventmachine'


module PolicyServer
  def post_init
    puts "-- someone connected to the echo server!"
  end

  def receive_data data
    puts "-- received #{data}, sending policy file"
    policy = <<EOF
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <allow-access-from domain="*" to-ports="*" />
</cross-domain-policy>
EOF
    puts policy
    send_data policy and close_connection_after_writing
  end

  def unbind
    puts "-- someone disconnected from the echo server!"
  end
end

EventMachine.run do
  EventMachine::start_server "0.0.0.0", 843, PolicyServer
end
