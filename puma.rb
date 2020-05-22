bind "unix://tmp/nginx.socket"
rackup DefaultRackup


on_worker_boot do
	FileUtils.touch('/tmp/app-initialized')
end
