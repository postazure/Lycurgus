require 'packages/package'

class BundlerPM
  def self.active?(repo_content)
    self if repo_content['tree'].find {|f| f['path'] == 'Gemfile.lock'}
  end

  def initialize(gemfile_lock_content)
    @content = gemfile_lock_content
  end

  def current_packages
    get_gem_info.map do |gem_info|
      Package.new(
        name: gem_info[0],
        version: gem_info[1]
      )
    end
  end

  private

  def get_gem_info
    gem_list = parse_dependencies_chunk
    dep_info_list = parse_spec_chunk

    gem_details = []
    dep_info_list.each do |dep_info|
      gem_details << dep_info if gem_list.include?(dep_info[0])
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

  def is_top_level(spec_line)
    spec_line[0..4].strip != spec_line[0..5].strip
  end

  def split_content
    @content.split("\n")
  end
end