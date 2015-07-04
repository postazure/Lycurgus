require 'api_client'
require 'repo'

class SearchController < ApplicationController
  API_ROOT = 'https://api.github.com'

  def new
  end

  def results
    repo_url = params[:repo_url].split('/')

    owner = repo_url[-2]
    repo_name  = repo_url[-1]

    sha = current_sha(owner, repo_name)

    repo_data = ApiClient.process_response(url: "#{API_ROOT}/repos/#{owner}/#{repo_name}/git/trees/#{sha}")
    repo = Repo.new(repo_data)
    deps = repo.current_packages

    render json: deps
  end

  private

  def current_sha(owner, repo_name)
    ApiClient.process_response(url: "#{API_ROOT}/repos/#{owner}/#{repo_name}/commits" )[0]['sha']
  end
end


