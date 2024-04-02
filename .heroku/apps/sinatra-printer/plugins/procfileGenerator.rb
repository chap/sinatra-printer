#!/usr/bin/env ruby
require 'yaml'
require 'net/http'
require 'uri'

#
# Load values from HerokuApp YAML and /Procfile
# Insert values into default k8s manifests
#


def load_and_parse_yaml(source)
  uri = URI.parse(source)

  if uri.scheme.nil? || uri.scheme.downcase == 'file'
    # Local file path
    raise "File not found: #{source}" unless File.exist?(source)

    yaml_content = File.read(source)
  else
    # Assume it's a URL
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      yaml_content = response.body
    else
      raise "Error loading YAML from #{source}. HTTP Response Code: #{response.code}"
    end
  end

  parsed_data = YAML.safe_load(yaml_content)
  raise YamlLoadError, "Error parsing YAML from #{source}" if parsed_data.nil?

  return parsed_data
end

# Split lines to {process: command, process: command}
def load_and_parse_procfile(source)
  procfile_content = File.read(source)
  lines = procfile_content.split("\n")
  parsed_data = {}

  lines.each do |line|
    parts   = line.split(':')
    process = parts[0].strip
    command = parts[1..-1].join(':').strip
    parsed_data[process] = command
  end
  return parsed_data
end


herokuApp = load_and_parse_yaml('herokuapp.yaml')
name      = herokuApp['metadata']['name']
pipeline  = herokuApp['spec']['pipeline']

templates = {
  'deployment' => load_and_parse_yaml('/Users/cambrose/Documents/clusters/src/defaults/app/deployment.yaml'),
  'service'    => load_and_parse_yaml('/Users/cambrose/Documents/clusters/src/defaults/app/service.yaml'),
  'appset'     => load_and_parse_yaml('/Users/cambrose/Documents/clusters/src/defaults/app/argocd-appset.yaml'),
}

processes = load_and_parse_procfile('../../../Procfile')
processes.each do |process, command|
  labels = {
    'procfile' => process,
    'app' => name
  }
  deployment = templates['deployment']
  deployment['metadata']['name'] = "#{name}-#{process}"
  deployment['metadata']['labels'] = labels
  deployment['spec']['selector']['matchLabels'] = labels
  deployment['spec']['template']['metadata']['labels'] = labels

  # update container command to match buildpack image defaults
  deployment['spec']['template']['spec']['containers'][0]['command'] = ["/cnb/process/#{process}"]

  puts deployment.to_yaml

  if process == 'web'
    service = templates['service'].clone
    service['metadata']['name'] = "#{name}-#{process}"
    service['metadata']['labels'] = labels
    puts service.to_yaml
  end
end

# Argo ApplicationSet
# each set is a stage in the pipeline
# updating the set will deploy all argo apps in the stage
pipeline.each_with_index do |pipeline_group,i|
  appset = templates['appset']
  appset['metadata']['name'] = "#{name}-#{i+1}"
  appset['spec']['template']['metadata']['name'] = "{{cluster}}-#{name}"

  elements = []
  pipeline_group = [pipeline_group] unless pipeline_group.is_a?(Array)
  pipeline_group.each do |target|
    elements << {
      'cluster' => target['cluster'],
      'url' => "#{target['cluster']}.herokucluster.com"
    }
  end
  appset['spec']['generators'] = [
    {'list' => {
        'elements' => elements
    }}
  ]
  puts appset.to_yaml
end
