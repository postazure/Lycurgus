require 'api_client'
require 'repo'

class SearchController < ApplicationController
  include SearchHelper

  LICENSE_ROOT = 'http://opensource.org'
  API_ROOT = 'https://api.github.com'

  def new
  end

  def results
    repo_info = repo_details(params)
    sha = current_sha(repo_info[:owner], repo_info[:repo_name])

    repo_data = ApiClient.process_response(url: "#{API_ROOT}/repos/#{repo_info[:owner]}/#{repo_info[:repo_name]}/git/trees/#{sha}")
    repo = Repo.new(repo_data)
    deps = repo.current_packages

    render json: deps
  end

  def commit_shas_gemfile_lock
    repo_info = repo_details(params)
    commits = find_commits_with_file({filename: 'Gemfile.lock'}.merge( repo_info ))
    render json: commits
  end

  def license_defs
    licenses = HTTParty.get(LICENSE_ROOT + '/licenses/alphabetical')
    render json: licenses_to_json(licenses)
  end
end


