class NodeProperties < Hash
  attr_accessor :node_identifier

  def initialize(node_identifier)
    @node_identifier = node_identifier
  end

  def []=(key,value)
    super key.to_s, ensure_numeric( value )
  end

  def [](key)
    super key.to_s
  end

  # Private methods
  
  def ensure_numeric(value)
    if value.kind_of? Numeric
      value
    elsif value.kind_of? String
      value.to_f
    else
      raise Daggregator::ValueError
    end
  end
end
