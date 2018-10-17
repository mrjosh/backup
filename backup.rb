require 'net/https'
require 'dotenv'
require 'json'
require 'git'

Dotenv.load(".env")

Git.configure do |config|
  config.binary_path = ENV['GIT_BINARY_PATH']
  config.git_ssh = ENV['GIT_SSH']
end

url = URI('https://gitlab.com/api/v4/groups/3733669/projects')
request = Net::HTTP::Get.new(url.request_uri)

request.add_field "Private-Token", ENV['PRIVATE_TOKEN']
http = Net::HTTP.new(url.host, url.port)

http.use_ssl = (url.scheme == "https")
response = http.request(request)

projects = JSON.parse(response.body)

projects.each do |project|

  project['http_url_to_repo'].sub! 'https://gitlab.com', 'https://oauth2:' + ENV['PRIVATE_TOKEN'] + '@gitlab.com'

  git = Git.clone(
      project['http_url_to_repo'], project['path'],
      :path => Dir.pwd + '/projects'
  )

  git.config('user.name', 'Alireza Josheghani')
  git.config('user.email', 'josheghani')
end