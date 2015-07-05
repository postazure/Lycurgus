require 'json'
require 'httparty'

class ApiClient

  def self.process_response(action: :get, url:, json: true)
    url = self.apply_auth(url)
    puts "[API CLIENT] #{action} => #{url}"
    response = HTTParty.send(action, url)
    json ? JSON.parse(response.body) : response.to_s
  end

  private
  def self.gh_auth(url)
    if url.include?('api.github.com') then
      params = "client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"
      url.include?('?') ? params.insert(0, '&') : params.insert(0, '?')
      return params
    else
      ''
    end
  end

  def self.apply_auth(url)
    url + gh_auth(url)
  end
end