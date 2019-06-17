#!/usr/bin/env ruby

require 'yaml'
require 'pp'
require 'json'
require './lib/mattermost_api.rb'

$config = YAML.load(
	File.open('conf.yaml').read
)['mattermost_api']

mm = MattermostApi.new(mattermost_url: $config['url'], 
						login_id: $config['username'],
						password: $config['password'])


if ARGV.length < 1
	puts "Must be called with at least one argument"
	exit!
end

# First argument should be the import file
file_path = ARGV[0]

if File.file?(file_path)
	import_file = File.open(file_path, 'r')
else
	puts "#{file_path} does not exist"
	exit!
end

if !ARGV[1].nil? and ARGV[1] == '--apply'
	update_users = true
else
	update_users = false
end

import_file.each_line do |line|
	json_line = JSON.parse(line)

	if json_line['type'] != 'user'
		next
	end

	pp json_line

	if update_users
		# Update the user
	end
end

import_file.close