require 'net/http'

def get_user_input(default_value, variable_name, prompt)
  print "#{prompt} [#{default_value}]: "
  user_input = gets.chomp
  user_input = default_value if user_input.empty?
  if user_input.downcase == 'y' || user_input.downcase == 'yes'
    user_input = true
  elsif user_input.downcase == 'n' || user_input.downcase == 'no'
    user_input = false
  end
  user_input
end

default_project_name = 'My Awesome Project'
project_name = get_user_input(default_project_name, 'project_name', 'Project name')

default_project_slug = project_name.downcase.gsub(' ', '_')
project_slug = get_user_input(default_project_slug, 'project_slug', 'Project slug')

ruby_version = get_user_input(RUBY_VERSION, 'ruby_version', 'Ruby version')

default_description = "Behold #{project_name}"
description = get_user_input(default_description, 'description', 'Description')

default_author_name = 'John Doe'
author_name = get_user_input(default_author_name, 'author_name', 'Author name')

default_author_email = 'john.doe@mail.com'
email = get_user_input(default_author_email, 'email', 'Email')

default_version = '0.1.0'
version = get_user_input(default_version, 'version', 'Version')

default_timezone = 'UTC'
timezone = get_user_input(default_timezone, 'timezone', 'Timezone')

default_license = '5'
open_source_license = get_user_input(default_license, 'open_source_license', "Select open_source_license:
1 - MIT
2 - BSD
3 - GPLv3
4 - Apache Software License 2.0
5 - None
Choose from 1, 2, 3, 4, 5")

use_sinatra = get_user_input('n', 'use_sinatra', 'Use Sinatra')
web_server = nil
web_server = get_user_input('1', 'web_server', "Select web_server:
  1 - Puma
  2 - Rack
  3 - Unicorn
  4 - Thin
  5 - WEBrick
  Choose from 1, 2, 3, 4, 5") if use_sinatra

use_mongo = get_user_input('n', 'use_mongo', 'use_mongo')

mongo_odm = nil
mongo_odm = get_user_input('1', 'mongo_odm', "Select mongo_odm:
1 - Mongoid
2 - EmeraldODM
3 - None
Choose from 1, 2, 3") if use_mongo

use_elasticsearch = get_user_input('n', 'use_elasticsearch', 'use_elasticsearch')

elasticsearch_odm = nil
elasticsearch_odm = get_user_input('1', 'elasticsearch_odm', "Select elasticsearch_odm:
1 - Chewy
2 - AmberODM
3 - None
Choose from 1, 2, 3") if use_elasticsearch

use_parallel = get_user_input('n', 'use_parallel', 'Use Parallel')

use_telegram_alerts = get_user_input('n', 'use_telegram_alerts', 'Use Telegram Alerts')

Dir.mkdir(project_slug) unless Dir.exist?(project_slug)

# Git init
Dir.chdir(project_slug) do
  system('git init')
end

File.open("#{project_slug}/Gemfile", 'w') do |f|
  f.puts "source \"https://rubygems.org\"\n\n"
  f.puts "git_source(:github) { |repo| \"https://github.com/\#{repo}.git\" }\n\n"
  f.puts "ruby \"#{ruby_version}\"\n\n"

  f.puts "gem 'sinatra'" if use_sinatra
  f.puts "gem 'puma'" if use_sinatra && web_server == '1'
  f.puts "gem 'rack'" if use_sinatra && web_server == '2'
  f.puts "gem 'unicorn'" if use_sinatra && web_server == '3'
  f.puts "gem 'thin'" if use_sinatra && web_server == '4'
  f.puts "gem 'webrick'" if use_sinatra && web_server == '5'

  f.puts "gem 'elasticsearch'" if use_elasticsearch
  f.puts "gem 'chewy'" if use_elasticsearch && elasticsearch_odm == '1'
  f.puts "gem 'amber_odm'" if use_elasticsearch && elasticsearch_odm == '2'

  f.puts "gem 'mongo'" if use_mongo
  f.puts "gem 'mongoid'" if use_mongo && mongo_odm == '1'
  f.puts "gem 'emerald_odm'" if use_mongo && mongo_odm == '2'

  f.puts "gem 'parallel'" if use_parallel
  f.puts "gem 'ruby-progressbar'" if use_parallel

  f.puts "gem 'telegram_alerts'" if use_telegram_alerts

  f.puts "gem 'dotenv'"
  f.puts "gem 'pry', group: 'development'"
  f.puts "gem 'colorize', group: 'development'"
  # f.puts "gem \"json\"\n\n"
end

[
  '.env',
  '.env.example',
].each do |file_name|
  File.open("#{project_slug}/#{file_name}", 'w') do |f|
    f.puts "MONGO_LOGIN=user" if use_mongo && mongo_odm == '2'
    f.puts "MONGO_PASSWD=passwd" if use_mongo && mongo_odm == '2'
    f.puts "MONGO_AUTH_SOURCE=admin\n\n" if use_mongo && mongo_odm == '2'
    if use_telegram_alerts
      f.puts "TELEGRAM_BOT_TOKEN=bot_token"
      f.puts "TELEGRAM_CHAT_ID=chat_id"
    end
  end
end

File.open("#{project_slug}/.ruby-version", 'w') do |f|
  f.puts "#{ruby_version}@#{project_slug}"
end

gitignore_contents = Net::HTTP.get(URI('https://raw.githubusercontent.com/github/gitignore/main/Ruby.gitignore'))
File.open("#{project_slug}/.gitignore", 'w') do |f|
  f.puts gitignore_contents
end

license = nil
license_label = 'None'

if open_source_license == '1'
  license_label = 'MIT'
  license = 'https://raw.githubusercontent.com/licenses/license-templates/master/templates/mit.txt'
elsif open_source_license == '2'
  license_label = 'BSD'
  license = 'https://raw.githubusercontent.com/licenses/license-templates/master/templates/bsd3.txt'
elsif open_source_license == '3'
  license_label = 'GPLv3'
  license = 'https://raw.githubusercontent.com/licenses/license-templates/master/templates/gpl3.txt'
elsif open_source_license == '4'
  license_label = 'Apache Software License 2.0'
  license = 'https://raw.githubusercontent.com/licenses/license-templates/master/templates/apache.txt'
elsif open_source_license == '5'
  license_label = 'None'
end

unless license.nil?
  license_contents = Net::HTTP.get(URI(license))
  File.open("#{project_slug}/LICENSE", 'w') do |f|
    f.puts license_contents
  end
end

File.open("#{project_slug}/README.md", 'w') do |f|
  f.puts "# #{project_name}"
  f.puts description
  f.puts "## About"
  f.puts "This project was created by #{author_name} <#{email}>"
  f.puts "## Usage"
  f.puts "## Contributing"
  f.puts "Bug reports and pull requests are welcome"
  f.puts "## License" if license_label != 'None'
  f.puts "This project is available as open source under the terms of the #{license_label} License" unless license_label == 'None'
end

Dir.mkdir("#{project_slug}/config") unless File.exist?("#{project_slug}/lib")

File.open("#{project_slug}/config/settings.rb", 'w') do |f|
  f.puts "module Settings\n\n"
  if use_mongo && mongo_odm == '2'
    f.puts "  MONGO_DATABASES = {\n"
    f.puts "    development: [
      [ '192.168.0.1:27017', '192.168.1.1:27017'],
      {
        database: 'development',
        user: ENV['MONGO_LOGIN'],
        password: ENV['MONGO_PASSWD'],
        auth_source:  ENV['MONGO_AUTH_SOURCE'],
        max_pool_size: 20,
      }
    ],\n"
    f.puts "  }\n\n"
  end
  if use_elasticsearch && elasticsearch_odm == '2'
    f.puts "  ELASTICSEARCH_DATABASES = {\n"
    f.puts "    development: { url: 'http://localhost:9200', log: true}\n"
    f.puts "  }\n\n"
  end
  if use_telegram_alerts
    f.puts "  TELEGRAM_ALERTS = {\n"
    f.puts "    watcher: {\n"
    f.puts "      bot_token: ENV['TELEGRAM_BOT_TOKEN'],\n"
    f.puts "      chat_id: ENV['TELEGRAM_CHAT_ID'],\n"
    f.puts "      host_name: `hostname`.strip,\n"
    f.puts "      project_name: '#{project_name}',\n"
    f.puts "    }\n"
    f.puts "  }\n\n"
  end
  f.puts "  TIMEZONE = '#{timezone}'"
  f.puts "  VERSION = '#{version}'"
  f.puts "end"
end

File.open("#{project_slug}/config/telegram_alerts_chats.rb", 'w') do |f|
  f.puts "module TelegramAlertsChats\n\n"
  f.puts "  class Watcher < TelegramAlerts::ChatMixin\n"
  f.puts "    def self.chat\n"
  f.puts "      :watcher\n"
  f.puts "    end\n\n"
  f.puts "  end\n"
  f.puts "end"
end if use_telegram_alerts

Dir.mkdir("#{project_slug}/models") if !Dir.exist?("#{project_slug}/lib") && (use_mongo || use_elasticsearch)

File.open("#{project_slug}/config/boot.rb", 'w') do |f|
  f.puts "require 'bundler/setup'\n\n"
  f.puts "Bundler.require(:default)\n\n"
  f.puts "# Env\n# #{'=' * 80}\n"
  f.puts "dot_env_path = File.join(File.dirname(__FILE__), '../', '.env')\n"
  f.puts "raise 'No .env file found' unless File.exist?(dot_env_path)\n"
  f.puts "Dotenv.load(dot_env_path)\n\n"
  if use_mongo
    f.puts "Mongo::Logger.logger = Logger.new('mongo.log')\nMongo::Logger.logger.level = Logger::INFO\n\n"
  end
  f.puts "# Settings\n# #{'=' * 80}\n"
  f.puts "require_relative 'settings'\n\n"
  f.puts "ENV['TZ'] = Settings::TIMEZONE\n\n"
  if use_mongo && mongo_odm == '2'
    f.puts "EmeraldODM.databases_settings.merge!(Settings::MONGO_DATABASES)\n"
    f.puts "EmeraldODM::Connector.database(:development) # Connect to the database for the first time\n\n"
  end
  if use_elasticsearch && elasticsearch_odm == '2'
    f.puts "AmberODM.databases_settings.merge!(Settings::ELASTICSEARCH_DATABASES)\n"
    f.puts "AmberODM::Connector.database(:development) # Connect to the database for the first time\n\n"
  end

  if use_telegram_alerts
    f.puts "TelegramAlerts.chats_settings.merge!(Settings::TELEGRAM_ALERTS)\n\n"

    f.puts "require_relative 'telegram_alerts_chats'\n\n"
  end
  # f.puts "Dir.glob('./lib/**/*.rb').each { |file| require file }\n\n"
end
