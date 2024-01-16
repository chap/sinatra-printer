#!/usr/bin/env ruby
yaml_string = <<~YAML
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: sinatra-printer-1
spec:
  generators:
  - list:
      elements:
      - cluster: REPLACE
        url: REPLACE
  template:
    metadata:
      name: sinatra-printer-{{cluster}}
    spec:
      destination:
        server: '{{url}}'
      project: default
---
YAML

puts yaml_string
