require 'packages/package'
require 'parsers/gemfile_lock_parser'
require 'api_client'

class BundlerPM
  def self.active?(repo_content)
    self if repo_content['tree'].find {|f| f['path'] == 'Gemfile.lock'}
  end

  def initialize(repo_info)
    @gemfile_lock_url = get_file_url_at_sha(repo_info)
  end

  def current_packages
    @content = ApiClient.process_response(url: @gemfile_lock_url, json: false)
    parsed_file = GemfileLockParser.new(@content).parse
    serialized_gems = serialize_gems(parsed_file)
    gems = compile_with_rubygems!(serialized_gems)

    gems.map do |gem_info|
      Package.new(gem_info)
    end
  end

  private
  def get_file_url_at_sha(tree_url)
    tree_url['url'].gsub('api.github.com/repos', 'raw.githubusercontent.com').gsub('git/trees', 'master').split('/')[0..-2].join('/') + '/Gemfile.lock'
  end

  def serialize_gems(parsed_gemlock)
    deps = []
    parsed_gemlock.map do |gem_source|
      source = gem_source[:source]
      sha = gem_source[:sha]
      gem_source[:deps].each do |dep|
        deps << {
            name: dep[:name],
            version: dep[:version],
            sha: sha,
            source: source
        }
      end
    end
    deps
  end

  def include_additional_info(dep_arr)
    dep_hash = {name: dep_arr[0], version: dep_arr[1]}
    api_url = "https://rubygems.org/api/v1/versions/#{dep_hash[:name]}.json"
    response = ApiClient.process_response(url: api_url)

    matched_response = response.find { |release| release['number'] == dep_hash[:version]}

    dep_hash.merge({sha: matched_response['sha'], licenses: matched_response['licenses'], source: api_url})
  end

  def compile_with_rubygems!(serialized_gems)
    serialized_gems.each do |gem|
      api_url = "https://rubygems.org/api/v1/versions/#{gem[:name]}.json"
      response = ApiClient.process_response(url: api_url)
      gem[:notices] ||= []

      matched_response = response.find { |release| release['number'] == gem[:version]}
      if matched_response.nil?
        matched_response = response.find { |release| release['number'].include?(gem[:version])}
        if matched_response.nil?
          gem[:notices] << {version: 'Version for dependency does not match. Most recent release referenced.'}
          matched_response = response.first
        else
          gem[:notices] << {version: "No exact match for version, found license info for version #{matched_response['number'] || 'n/a'}."}
        end
      end

      gem[:sha] ||= matched_response['sha']
      if matched_response['licenses'].nil? || matched_response['licenses'].empty?
        gem[:notices] << {licenses: 'Gem has no license.'}
        gem[:licenses] = []
      else
        gem[:licenses] = matched_response['licenses']
      end
    end
    serialized_gems
  end
end