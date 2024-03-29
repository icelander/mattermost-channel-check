require 'httparty'
require 'time'
require 'digest'
require 'pp'
require 'fileutils'
require 'uri'

class MattermostApi
	include HTTParty

	format :json
	# debug_output $stdout
	
	def initialize(mattermost_url: nil, login_id: nil, password: nil, token: nil)
		if mattermost_url.nil?
			raise 'mattermost_url must be set'
		else
			# Parse the URL
			uri = URI(mattermost_url)
			
			@base_uri = uri.scheme + '://' + uri.host + ':' + uri.port.to_s + '/api/v4/'
			
		end

		if login_id.nil? and password.nil? and token.nil?
			raise 'Set either login_id and password or token'
		end
		
		if token.nil?
			@login_id = login_id
			@password = password

			tmp_dir = './tmp/'

			unless File.directory?(tmp_dir)
			  FileUtils.mkdir_p(tmp_dir)
			end

			@tmp_file = tmp_dir + Digest::MD5.hexdigest("#{login_id}")

			@options = {
				headers: {
					'Content-Type' => 'application/json',
					'User-Agent' => 'Mattermost-HTTParty'
				},
				# TODO Make this more secure
				verify: false
			}
			
			token = nil
			
			begin
				if File.file?(@tmp_file) && File.readable?(@tmp_file)
					token = JSON.parse(File.read(@tmp_file))
					if Time.now < Time.parse(token['expiration'])
						token = token['value']
					end
				end
			rescue Exception => e
				pp e
			end

			if token.nil?
				token = handle_login	
			end
		end		
		
		@options[:headers]['Authorization'] = "Bearer #{token}"
		@options[:body] = nil

	end

	def post_data(payload, request_url)
		options = @options
		options[:body] = payload.to_json

		self.class.post("#{@base_uri}#{request_url}", options)
	end

	def get_url(url)
		response = self.class.get("#{@base_uri}#{url}", @options)
		
		returns = JSON.parse(response.to_s)
		# pp returns

		returns
	end

	def get_users_by_auth(auth_method)
		per_page = 60
		current_page = 0

		output_users = {}

		if auth_method == 'email'
			auth_method = ''
		end

		loop do
			url = "/users?page=#{current_page}"
			users = self.get_url(url)

			break if users.count == 0

			users.each do |user|
				if user['auth_service'] == auth_method
					output_users[user['email']] = user['username'].to_s
				end
			end

			current_page += 1
		end

		return output_users
	end

	private

	def handle_login
		login_options = @options
		login_options[:headers]['Content-Type' => 'application/x-www-form-urlencoded']
		login_options[:body] = {'login_id' => @login_id, 'password' => @password}.to_json

		login_response = self.class.post("#{@base_uri}users/login", login_options) 

		headers = login_response.headers

		if headers['Token'].kind_of?(Array)
			token = headers['Token'][0]
		else
			token = headers['Token'][0]
		end

		token
	end
end