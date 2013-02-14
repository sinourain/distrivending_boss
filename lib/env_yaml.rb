require 'yaml'

env_hash = nil

config_file = "env.yml"

begin
  env_yaml = YAML.load_file(File.dirname(__FILE__) + "/../config/#{config_file}")
  env_hash = env_yaml[ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'] || {}
  if env_hash
    env_hash.each_pair do |k,v|
      ENV[k] = v.to_s
    end
  end
rescue StandardError => e
  puts "WARNING - Could not find #{config_file} !! -- Set environment variables directly"
  env_hash = {}
end
