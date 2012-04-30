class Node
  attr_accessor :identifier

  def self.find_by_identifier(identifier)
    node = Node.new(:identifier => identifier)
    node.fetch_node_attributes
    node
  end

  def self.create(attrs)
    Node.new(attrs).save!
  end

  def initialize(attrs)
    attrs = {identifier: attrs} if attrs.kind_of? String
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

  def node_url
    @node_url ||= fetch_node_attributes['self']
  end

  def node_id
    node_url.match(/db\/data\/node\/(\d+)$/)[1].to_i # This feels dangerously hacky, but neography doesn't seem to return the ID
  end

  def flow_to(target)
    Flow.new(self, target)
  end

  def flow_to!(target)
    flow_to(target).save!
  end

  def target_identifiers
    query = <<-CYPHER
      start n=node({id})
      match (n)-->(target)
      return target.identifier
    CYPHER
    execute_query(query, {id: node_id})["data"].map(&:first) # LOT of shit has to go right for this to work...
  end

  # Private Methods
  
  def execute_query(query, params)
    $neo.execute_query(query, params)
  end

  def fetch_node_attributes
    response = $neo.get_node_index(:identifier, 'identifier', identifier)
    data.merge! response.first['data']
    @node_url = response.first['self']
    response.first
  end

  def set_node_properties(properties)
    response = $neo.create_unique_node(:identifier, 'identifier', identifier, {identifier: identifier}.merge(data))
  end
end
