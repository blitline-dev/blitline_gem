module AttributeJsonizer
  require 'multi_json'

  def add_jsonizable_attribute(json_name, jsonizeable_object)
    self.class.module_eval { attr_accessor json_name.to_sym}
    self.send("#{json_name.to_s}=", jsonizeable_object)
  end

  def to_json(options)
    json_hash = {}
    self.instance_variables.each do |iv|
      key = iv
      value = self.instance_variable_get(iv)
      json_hash[key.to_s.gsub("@","")] = value unless value.kind_of?(Array) && value.length == 0 #Bail on empty arrays
    end
    MultiJson.dump(json_hash)
  end
end
