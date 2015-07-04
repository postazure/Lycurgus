class Package
  attr_reader :name, :version, :licenses, :sha, :source
  def initialize(name:, version:, licenses: ["No License"], sha: "No Sha", source: "No Source")
    @name = name
    @version = version
    @licenses = licenses
    @sha = sha
    @source = source
  end
end