module Coveralls
	class API

		require 'json'
		require 'rest_client'

		# API_BASE = "http://coveralls.dev/api/ruby"
		API_BASE = "http://coveralls.herokuapp.com/api/ruby"

		def self.post_json(endpoint, hash)
			url = endpoint_to_url(endpoint)
			puts "Coveralls posting to url: #{url}"
			RestClient.post(url, :json_file => hash_to_file(hash))
			puts "...posted."
		end

		private

		def self.endpoint_to_url(endpoint)
			"#{API_BASE}/#{endpoint}"
		end

		def self.hash_to_file(hash)
			hash = apified_hash hash
			file = Tempfile.new(['coveralls-upload', 'json'])
			file.write hash.to_json
			File.new(file.path, 'rb')
		end

		def self.apified_hash hash
			hash.merge(travis_job_id: ENV['TRAVIS_JOB_ID'])
		end
	
	end
end