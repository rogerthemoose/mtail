@@LINES_OF_CONTEXT = 100

@users = [
  { :id => :vagrant }
]

@files = [
  { :id => :web, :path => '/var/log/argh.log' },
  { :id => :perf, :path => '/var/log/urgh.log' },
]

@hosts = [
  { :hostname => 'localhost', :port => 41022, :id => 'oraxe', :user => :vagrant, :files => [ :web, :perf ] },
  { :hostname => 'localhost', :port => 42022, :id => 'graphite', :user => :vagrant, :files => [ :web ] }
]
