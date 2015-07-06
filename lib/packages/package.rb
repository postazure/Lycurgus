class Package
  attr_reader :name, :version, :licenses, :sha, :source, :notices
  def initialize(name:, version:, licenses:, sha:, source:, notices:)
    @name = name
    @version = version
    @licenses = licenses
    @sha = sha
    @source = source
    @notices = notices
  end
end