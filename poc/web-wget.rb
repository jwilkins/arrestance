require 'rubygems'
require 'net/ssh'
require 'amatch'
require 'ruby-debug'
require 'differ'

include Amatch
Differ.format = :color

$cmd = "wget -q -O - "
def check_local(url)
  `#{$cmd} #{url}`
end

def check_remote(url, host, user, pass)
  Net::SSH.start(host, user, :password => pass) { |ssh|
    return ssh.exec!("#{$cmd} #{url}")
  }
end

%w(http://google.com/ http://www.eff.org/).each { |url|
  local = check_local(url)
  remote = check_remote(url, 'hostname', 'username', 'password')
  score = JaroWinkler.new(remote).match(local)
  if score == 1.0
    puts "#{'-'*40}\n#{url} matches"
  else
    puts "#{'-'*40}\n#{url} doesn't match"
    diff = Differ.diff_by_char(remote, local)
    puts diff
  end

}

