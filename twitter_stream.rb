require 'rubygems'
require 'active_support'
require 'yajl'

lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
 
require 'twitter/json_stream'
 
EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :path    => '/1/statuses/filter.json',
    :auth    => 'ende42:niko00',
    :method  => 'POST',
    :content => 'track=music'
  )
    
  stream.each_item do |item|
    msg = Yajl::Parser.parse(item)
    name = msg["user"]["name"]
    time = Time.parse(msg["created_at"]).to_s(:long)
    msg = msg["text"].gsub(/music/i, "\e[31mMUSIC\e[0m")

    $stdout.print %Q{#{name} (#{time}): #{msg}\n\n}
    $stdout.flush
  end
  
  stream.on_error do |message|
    $stdout.print "error: #{message}\n"
    $stdout.flush
  end
  
  stream.on_reconnect do |timeout, retries|
    $stdout.print "reconnecting in: #{timeout} seconds\n"
    $stdout.flush
  end
  
  stream.on_max_reconnects do |timeout, retries|
    $stdout.print "Failed after #{retries} failed reconnects\n"
    $stdout.flush
  end
  
  trap('TERM') {  
    stream.stop
    EventMachine.stop if EventMachine.reactor_running? 
  }
}
puts "The event loop has ended"
