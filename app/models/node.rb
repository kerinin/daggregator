class Node
  attr_accessor :identifier

  def initialize(attrs)
    attrs.symbolize_keys!

    @identifier = attrs[:identifier].to_s

    attrs[:data].try(:each_pair) do |key,value|
      data[key] = value
    end
  end

  def save
    begin
      save!
    rescue
      false
    else
      true
    end
  end

  def save!
    set_node_properties( {'identifier' => identifier}.merge(data) )
    self
  end

  def data
    @data ||= NodeProperties.new
  end

  # Private Methods

  def set_node_properties(properties)
  end
end
