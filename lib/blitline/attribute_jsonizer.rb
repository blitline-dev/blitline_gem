module AttributeJsonizer
  require 'yajl'

  def to_json
    json_hash = {}
    self.instance_variables.each do |iv|
      key = iv
      value = self.instance_variable_get(iv)
      json_hash[key.to_s.gsub("@","")] = value
    end
    Yajl::Encoder.encode(json_hash)
  end
end