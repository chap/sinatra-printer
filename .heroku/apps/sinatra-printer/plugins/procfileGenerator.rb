#!/usr/bin/env ruby

require 'yaml'

# Load app name from herokuapp.yaml
yaml_file_path = 'herokuapp.yaml'
yaml_content = File.read(yaml_file_path)
parsed_yaml = YAML.safe_load(yaml_content)
name = parsed_yaml['metadata']['name']

# Read contents from the Procfile
procfile_path = '../../../Procfile'
profile = File.read(procfile_path)

# Split the profile into lines
lines = profile.split("\n")

# Parse each line
lines.each do |line|
  # Split each line into parts
  parts = line.split(':')

  # Extract the process type and command
  process = parts[0].strip
  command = parts[1..-1].join(':').strip

  puts <<~YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: #{name}-#{process}
    spec:
      replicas: 1
      # revisionHistoryLimit: 3
      # revisionHistoryLimit: 10 # TODO: Default to 10 if not specified
      selector:
        matchLabels:
          app: DEFAULT
      template:
        metadata:
          labels:
            app: DEFAULT
        spec:
          containers:
          - name: DEFAULT
            image: DEFAULT
            command: ['#{command}']
    ---
  YAML

  # Create Service (load balancer) for web ingress
  if process == 'web'
    puts <<~YAML
      apiVersion: v1
      kind: Service
      metadata:
        name: #{name}-web
      spec:
        type: LoadBalancer
        ports:
        - port: 80
          targetPort: 8080
        selector:
          app: DEFAULT-web
    ---
    YAML
  end
end
