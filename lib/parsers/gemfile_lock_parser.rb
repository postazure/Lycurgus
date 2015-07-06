class GemfileLockParser
  SOURCE_HEADERS = ['GEM', 'GIT']

  def initialize(gemfile_lock)
    @content = gemfile_lock
    @pointer = 0
    @deps_list = []
  end

  def parse
    loop do
      if SOURCE_HEADERS.include?(split_content[@pointer])
        @deps_list << {
            source: get_line('*'),
            remote: get_line('remote'),
            sha: get_line('revision'),
            deps: get_deps
        }
      end

      break if @pointer == split_content.length
      @pointer += 1
    end

    @deps_list
  end

  private
  def split_content
    @content.split("\n")
  end

  def get_line(expected_key)
    if split_content[@pointer].include?(expected_key) || expected_key == '*'
      value = split_content[@pointer].gsub(expected_key + ':', '').strip
      @pointer += 1
    end
    value ||= nil
  end

  def get_deps
    deps = []
    loop do
      break if split_content[@pointer] == ""
      deps << dep_details if is_primary_dep
      @pointer += 1
    end
    deps
  end

  def is_primary_dep
    line = split_content[@pointer]
    (line[0..3].strip == '') && (line[0..4].strip != line[0..5].strip)
  end

  def dep_details
    split_line = split_content[@pointer].split(' ')
    name = split_line[0]
    version = split_line[1] ? split_line[1].gsub('(', '').gsub(')', '') : 'No Version'
    { name: name, version: version }
  end
end
