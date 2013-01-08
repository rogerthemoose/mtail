require 'net/ssh'
require 'highline/import'

if (ARGV.length != 1)
  puts "Usage: ruby tail.rb <configuration.rb>" unless ARGV.length == 1
  exit
end

#load local config file
require_relative ARGV[0]

def get_password_for(user)
  ask("Please enter the ssh password for #{user}") {|q| q.echo = false}
end

def do_tail( session, id, fileId, filePath )
  checkForFile = session.exec! "ls #{filePath}"
  if (checkForFile =~ /no such file/i)
    puts "!!! WARNING !!! No file at #{filePath} on #{id} yet"
  else
    session.open_channel do |channel|
      channel.on_data do |ch, data|
        data.split(/\n/).each do |line|
          puts "[#{id.ljust(8)} : #{fileId.ljust(5)}] -> #{line}"
        end
      end
      channel.exec "tail -F -n #{@@LINES_OF_CONTEXT} #{filePath}"
    end
  end
end

def get_user_with_password_for_id(userId)
  theUser = @users.find { |u| u[:id] == userId }
  theUser[:password] = get_password_for(theUser[:id].to_s) unless theUser.has_key?:password
  theUser
end

@threads = []

@hosts.each do |host|
  theUser = get_user_with_password_for_id(host[:user])
  @threads << Thread.new(host) { |aHost|
    Net::SSH.start(aHost[:hostname], theUser[:id].to_s, :port => aHost[:port] || 22, :password => theUser[:password]) do |ssh|
      aHost[:files].each do |fileId|
        theFile = @files.find { |f| f[:id] == fileId }
        do_tail ssh, aHost[:id], fileId.to_s, theFile[:path]
      end
      ssh.loop
    end
  }
end

@threads.each { |aThread|  aThread.join }