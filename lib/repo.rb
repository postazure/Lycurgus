require 'api_client'
require 'package_managers/bundler_p_m'

class Repo
  API_ROOT = 'https://api.github.com/repos/'
  PACKAGE_MANAGERS = [BundlerPM]

  attr_reader :name, :owner, :sha
  def initialize(github_json)
    @content  = github_json
    @api_url  = @content['url']
    @owner    = url_highlights[0]
    @name     = url_highlights[1]
    @sha      = url_highlights.last
  end

  def url
    "github.com/#{owner}/#{name}"
  end

  def current_packages
    active_pms.map do |pm|
      pm.send(:new, @content).send(:current_packages)
    end.flatten
  end


  private
  def active_pms
    PACKAGE_MANAGERS.map {|pm| pm.send(:active?, @content) }.compact
  end

  def url_highlights
    @api_url
        .gsub(API_ROOT, '')
        .split('/')
  end

end

