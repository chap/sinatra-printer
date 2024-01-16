#!/usr/bin/env ruby
require 'yaml'
require 'net/http'
require 'uri'

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

def load_and_parse_procfile(source)
  procfile_content = File.read(source)
  lines = procfile_content.split("\n")
  parsed_data = {}

  # Split lines to {process: command, process: command}
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


output    = []
templates = {
  'deployment' => load_and_parse_yaml('/Users/chapambrose/Documents/clusters/src/defaults/app/deployment.yaml'),
  'service'    => load_and_parse_yaml('/Users/chapambrose/Documents/clusters/src/defaults/app/service.yaml'),
  'appset'     => load_and_parse_yaml('/Users/chapambrose/Documents/clusters/src/defaults/app/argocd-appset.yaml'),
}

processes = load_and_parse_procfile('../../../Procfile')
processes.each do |process, command|
  deployment = templates['deployment']
  deployment['metadata']['name'] = "#{name}-#{process}"
  puts deployment.to_yaml

  if process == 'web'
    service = templates['service'].clone
    service['metadata']['name'] = "#{name}-#{process}"
    puts service.to_yaml
  end
end
