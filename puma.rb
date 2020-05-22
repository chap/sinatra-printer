workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['THREAD_COUNT'] || 5)
threads threads_count, threads_count

bind "unix://tmp/nginx.socket"
rackup DefaultRackup

on_worker_boot do
  FileUtils.touch('/tmp/app-initialized')
end
