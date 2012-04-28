class Node < ActiveRecord::Base
  def key(name)
    data_key(name).merge aggregates_key(name)
  end

  def data_key(name)
    data.select {|key| key.start_with? name }
  end

  def aggregates_key(name)
    aggregates.select {|key| key.start_with? name }
  end

  def data=(hash)
    self.data_json = floatify_string_values(hash).to_json
  end

  def data
    if data_json.nil?
      {}
    else
      JSON.parse(data_json).stringify_keys!
    end
  end

  def aggregates
    if aggregates_json.nil?
      {}
    else
      JSON.parse(aggregates_json)
    end
  end

  # Private methods
  
  def floatify_string_values(hash)
    ret = {}
    hash.each_pair do |key,value|
      if value.kind_of? Hash
        ret[key] = floatify_string_values values
      elsif value.kind_of? Array
        ret[key] = value.map {|v| floatify_value v }
      else
        ret[key] = floatify_value value
      end
    end
    ret
  end

  def floatify_value(value)
    if value.kind_of? Numeric
      value
    else
      value.to_f
    end
  end
end
