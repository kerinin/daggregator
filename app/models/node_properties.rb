class NodeProperties < Hash
  def []=(key,value)
    super key.to_s, validate( value )
  end

  def [](key)
    super key.to_s
  end

  # Private methods
  
  def validate(value)
    if value.kind_of? Numeric
      value
    elsif value.kind_of? String and value.match(/^\s?([\d\.]+)\s?$/)
      $1.to_f
    elsif value.kind_of? String
      value
    else
      raise Daggregator::ValueError
    end
  end
end
