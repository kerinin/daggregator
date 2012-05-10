class NodeProperties < Hash
  def []=(key,value)
    super key.to_s, validate(key.to_s, value )
  end

  def [](key)
    super key.to_s
  end

  # Private methods
  
  def validate(key, value)
    case key
    when /^numeric:/
      if value.kind_of? Numeric
        value
      elsif value.kind_of? String
        value.to_f
      else
        raise Daggregator::ValueError
      end
    when /^text:/
      if value.kind_of? String
        value
      else
        raise Daggregator::ValueError
      end
    else
      raise Daggregator::ValueError
    end
  end
end
