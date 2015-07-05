require 'api_client'
require 'repo'

class SearchController < ApplicationController
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

  private

  def find_commits_with_file(filename:, owner:, repo_name:)
    url = "#{API_ROOT}/repos/#{owner}/#{repo_name}/commits?path=#{filename}"
    response = ApiClient.process_response(url: url)
    response.map do |commit|
      {
          sha: commit['sha'],
          date: commit['commit']['committer']['date'],
          message: commit['commit']['message'],
          url: commit['commit']['url']
      }
    end
  end

  def current_sha(owner, repo_name)
    ApiClient.process_response(url: "#{API_ROOT}/repos/#{owner}/#{repo_name}/commits" )[0]['sha']
  end

  def repo_details(params)
    repo_url = params[:repo_url].split('/')
    { owner: repo_url[-2], repo_name: repo_url[-1] }
  end
end


