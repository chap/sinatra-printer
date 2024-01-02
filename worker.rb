# write immediately
$stdout.sync = true

while true
  print Time.now
  sleep 60
end
