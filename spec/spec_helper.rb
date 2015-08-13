require "bundler/setup"
Bundler.setup
require "reqcon"
require "yaml"

reqconsample = YAML.load("test_data/reqcons_sample.yml.yaml")
parvalsample = YAML.load("test_data/parvals_sample.yml.yaml")