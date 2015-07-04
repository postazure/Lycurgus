require 'packages/package'
require 'api_client'

class BundlerPM
  def self.active?(repo_content)
    self if repo_content['tree'].find {|f| f['path'] == 'Gemfile.lock'}
  end

  def initialize(repo_info)
    url = get_file_url_at_sha(repo_info)
    @content = ApiClient.process_response(url: url, json: false)
  end

  def current_packages
    get_gem_info.map do |gem_info|
      Package.new(gem_info)
    end
  end

  private

  def get_file_url_at_sha(tree_url)
    tree_url['url'].gsub('api.github.com/repos', 'raw.githubusercontent.com').gsub('git/trees', 'master').split('/')[0..-2].join('/') + '/Gemfile.lock'
  end

  def get_gem_info
    gem_list = parse_dependencies_chunk
    dep_info_list = parse_spec_chunk

    gem_details = []
    dep_info_list.each do |dep|
      if gem_list.include?(dep[0])
        gem_details << include_additional_info(dep)
      end
    end
    gem_details
  end

  def parse_dependencies_chunk
    dep_start = split_content.index('DEPENDENCIES') + 1
    gem_lines = split_content[dep_start..-1]

    gem_lines.map do |gem_name|
      # Strip version preferences
      gem_name.gsub(/[(].{1,}[)]/, '').strip
    end
  end

  def parse_spec_chunk
    dep_start = split_content.index('  specs:') + 1
    dep_end = split_content.index('PLATFORMS') - 1
    dep_lines = split_content[dep_start..dep_end]

    dep_lines.map do |dep_line|
      next unless is_top_level(dep_line)
      dep_info = dep_line.split(' ')
      name = dep_info[0]
      version = dep_info[1] ? dep_info[1].gsub('(', '').gsub(')', '') : 'No Version'
      [name, version]
    end.compact
  end

  def include_additional_info(dep_arr)
    dep_hash = {name: dep_arr[0], version: dep_arr[1]}
    api_url = "https://rubygems.org/api/v1/versions/#{dep_hash[:name]}.json"
    response = ApiClient.process_response(url: api_url)

    matched_response = response.find { |release| release['number'] == dep_hash[:version]}

    dep_hash.merge({sha: matched_response['sha'], licenses: matched_response['licenses'], source: api_url})
  end

  def is_top_level(spec_line)
    spec_line[0..4].strip != spec_line[0..5].strip
  end

  def split_content
    @content.split("\n")
  end
end