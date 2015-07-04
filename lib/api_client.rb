require 'json'
require 'httparty'

class ApiClient
  def self.github(action: :get, url:, headers: {}, json: true)
    response = HTTParty.get(url)
    json ? JSON.parse(response.body) : response.to_s
  end
end