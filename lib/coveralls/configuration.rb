module Coveralls
  module Configuration

    require 'yaml'

    def self.configuration
      config = {
        :environment => self.relevant_env, 
        :git => git
      }
      yml = self.yaml_config
      if yml
        config[:configuration] = yml
        config[:repo_token] = yml['repo_token'] || yml['repo_secret_token']
      end
      if ENV['COVERALLS_REPO_TOKEN']
        config[:repo_token] = ENV['COVERALLS_REPO_TOKEN']
      end
      if ENV['TRAVIS']
        config[:service_job_id] = ENV['TRAVIS_JOB_ID']
        config[:service_name]   = (yml ? yml['service_name'] : nil) || 'travis-ci'
      end
      if ENV["COVERALLS_RUN_LOCALLY"]
        config[:service_job_id] = nil
        config[:service_name]   = 'coveralls-ruby'
        config[:service_event_type] = 'manual'
      end
      config
    end

    def self.yaml_config
      if self.configuration_path && File.exists?(self.configuration_path)
        YAML::load_file(self.configuration_path)
      end
    end

    def self.configuration_path
      File.expand_path(File.join(self.root, ".coveralls.yml")) if self.root
    end

    def self.root
      pwd
    end

    def self.pwd
      Dir.pwd
    end

    def self.simplecov_root
      if defined?(::SimpleCov)
        ::SimpleCov.root
      end
    end

    def self.rails_root
      Rails.root.to_s
    rescue
      nil
    end

    def self.git
      hash = {}
 
      Dir.chdir(root) do

        hash[:head] = {
          :id => `git log -1 --pretty=format:'%H'`, 
          :author_name => `git log -1 --pretty=format:'%aN'`,
          :author_email => `git log -1 --pretty=format:'%ae'`,
          :committer_name => `git log -1 --pretty=format:'%cN'`,
          :committer_email => `git log -1 --pretty=format:'%ce'`,
          :message => `git log -1 --pretty=format:'%s'`
        }

        # Branch
        branch = `git branch`.split("\n").delete_if { |i| i[0] != "*" }
        hash[:branch] = [branch].flatten.first.gsub("* ","")

        # Remotes
        remotes = nil
        begin
          remotes = `git remote -v`.split(/\n/).map do |remote|
            splits = remote.split(" ").compact
            {:name => splits[0], :url => splits[1]}
          end.uniq
        rescue
        end
        hash[:remotes] = remotes

      end

      hash

    rescue Exception => e
      puts "Coveralls git error:".red
      puts e.to_s.red
      nil
    end

    def self.relevant_env
      {
        :travis_job_id => ENV['TRAVIS_JOB_ID'], 
        :travis_pull_request => ENV['TRAVIS_PULL_REQUEST'], 
        :pwd => self.pwd, 
        :rails_root => self.rails_root, 
        :simplecov_root => simplecov_root,
        :gem_version => VERSION
      }
    end

  end
end