require 'net/https'
require 'dotenv'
require 'json'
require 'git'

Dotenv.load(".env")

Git.configure do |config|
  config.binary_path = ENV['GIT_BINARY_PATH']
end

url = URI("https://gitlab.com/api/v4/groups/#{ENV['GROUP_ID']}/projects")
request = Net::HTTP::Get.new(url.request_uri)

if ENV['PRIVATE_TOKEN'] != nil
  request.add_field "Private-Token", ENV['PRIVATE_TOKEN']
end

http = Net::HTTP.new(url.host, url.port)

http.use_ssl = (url.scheme == "https")
response = http.request(request)

projects = JSON.parse(response.body)

projects.each do |project|

  if ENV['PRIVATE_TOKEN'] != nil
    project['http_url_to_repo'].sub! 'https://gitlab.com', 'https://oauth2:' + ENV['PRIVATE_TOKEN'] + '@gitlab.com'
  end

  git = Git.clone(
      project['http_url_to_repo'], project['path'],
      :path => Dir.pwd + '/projects'
  )

  git.config('user.name', ENV['GIT_USER_NAME'])
  git.config('user.email', ENV['GIT_USER_EMAIL'])
end