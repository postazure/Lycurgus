class SearchController < ApplicationController
  API_ROOT = 'https://api.github.com'

  def repo_content
    owner   = params[:owner]
    repo    = params[:repo]
    sha     = params[:sha]

    HTTParty.get(
      "#{API_ROOT}/repos/#{owner}/#{repo}/git/trees/#{sha}"
    )

    render json: {}
  end

end


