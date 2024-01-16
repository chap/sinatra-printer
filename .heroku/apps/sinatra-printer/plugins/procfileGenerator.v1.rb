#!/usr/bin/env ruby
require 'yaml'

def load_app_name(yaml_file_path)
  yaml_content = File.read(yaml_file_path)
  herokuapp_yaml = YAML.safe_load(yaml_content)
  herokuapp_yaml['metadata']['name']
end

def generate_deployment_yaml(name, process, command)
  <<~YAML
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: #{name}-#{process}
  spec:
    replicas: 1
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
end

def generate_service_yaml(name, process)
  return unless process == 'web'

  <<~YAML
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

def load_pipeline_targets(pipeline_group)
  pipeline_group.is_a?(Array) ? pipeline_group : [pipeline_group]
end

def generate_application_set_yaml(name, pipeline_group, index)
  elements = pipeline_group.each do |targets|
    cluster = targets['cluster']
    {
      'cluster' => targets['cluster'],
      'url' => "#{cluster}.herokucluster.com"
    }
  end

  yaml_string = <<~YAML
  apiVersion: argoproj.io/v1alpha1
  kind: ApplicationSet
  metadata:
    name: #{name}-#{index+1}
  spec:
    generators:
    - list:
        elements:
        - cluster: REPLACE
          url: REPLACE
    template:
      metadata:
        name: #{name}-{{cluster}}
      spec:
        project: default
        # source:
        #   repoURL: https://github.com/argoproj/argo-cd.git
        #   targetRevision: HEAD
        #   path: .heroku/apps/#{name}
        destination:
          server: '{{url}}'
  ---
  YAML

  puts yaml_string
end

# Load app name from herokuapp.yaml
yaml_file_path = 'herokuapp.yaml'
name = load_app_name(yaml_file_path)

# Read contents from the Procfile
procfile_path = '../../../Procfile'
profile = File.read(procfile_path)

# Split the profile into lines
lines = profile.split("\n")

# Parse each line
lines.each do |line|
  parts = line.split(':')
  process = parts[0].strip
  command = parts[1..-1].join(':').strip

  puts generate_deployment_yaml(name, process, command)
  puts generate_service_yaml(name, process)
end

# Load pipeline targets from herokuapp.yaml
yaml_content = File.read(yaml_file_path)
herokuapp_yaml = YAML.safe_load(yaml_content)
herokuapp_yaml['spec']['pipeline'].each_with_index do |pipeline_group, index|
  pipeline_group = load_pipeline_targets(pipeline_group)

  puts generate_application_set_yaml(name, pipeline_group, index)
end
