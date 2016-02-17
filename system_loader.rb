class SystemLoader
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def call
    raw_hash = raw_systems_hash
    hash = symbolise_system_values(raw_hash)
    symbolise_hash(hash)
  end

  private

  def systems_json
    File.new(file_path).read
  end

  def raw_systems_hash
    JSON.parse(systems_json)
  end

  def symbolise_hash(hash)
    hash.inject({}) do |hash, (k,v)|
      hash[k.to_sym] = v
      hash
    end
  end

  def symbolise_system_values(hash)
    hash.each do |k,v|
      hash[k] = symbolise_hash(v)
    end
  end
end