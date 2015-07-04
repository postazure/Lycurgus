require 'json'
require 'httparty'

class ApiClient
  def self.process_response(action: :get, url:, json: true)
    response = HTTParty.send(action, url)
    json ? JSON.parse(response.body) : response.to_s
  end
end