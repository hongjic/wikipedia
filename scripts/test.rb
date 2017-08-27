require 'net/ssh'

host = 'beret.cs.brandeis.edu'
user = 'hadoop07'
password = 'nh4sX_b7pRxk'
Net::SSH.start(host, user, :password => password) do |ssh|
  output = ssh.exec!("ls")
  puts output
end
