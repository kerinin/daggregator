class Node
  attr_accessor :identifier

  def self.find_by_identifier(identifier)
    node = Node.new(:identifier => identifier)
    node.fetch_node_attributes
    node
  end

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

  def flow_to(target)
    Flow.new(self, target)
  end

  def flow_to!(target)
    flow_to(target).save!
  end

  # Private Methods

  def fetch_node_attributes
    response = $neo.get_node_index(:identifier, 'identifier', identifier)
    data.merge! response.first['data']
  end

  def set_node_properties(properties)
    response = $neo.create_unique_node(:identifier, 'identifier', identifier, data)
  end
end
