#!/usr/bin/env ruby

require 'yaml'
require 'pp'
require 'json'
require './lib/mattermost_api.rb'

$config = YAML.load(
	File.open('conf.yaml').read
)

mm = MattermostApi.new($config['mattermost_api']['url'],
				 	   $config['mattermost_api']['username'],
				 	   $config['mattermost_api']['password'])