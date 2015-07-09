module SearchHelper
  private
  def licenses_to_json(html)
    noko = Nokogiri::HTML(html)
    license_lis = noko.css('div.field-item > ul a')
    license_lis.map do |a|
      {
          name: a.text.gsub(/[\s]\(.*?\)/, ''), #remove short name
          url: SearchController::LICENSE_ROOT + a['href'],
          short: a['href'].gsub('/licenses/', '')
      }
    end
  end

  def find_commits_with_file(filename:, owner:, repo_name:)
    url = "#{SearchController::API_ROOT}/repos/#{owner}/#{repo_name}/commits?path=#{filename}"
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
    ApiClient.process_response(url: "#{SearchController::API_ROOT}/repos/#{owner}/#{repo_name}/commits" )[0]['sha']
  end

  def repo_details(params)
    repo_url = params[:repo_url].split('/')
    { owner: repo_url[-2], repo_name: repo_url[-1] }
  end
end
