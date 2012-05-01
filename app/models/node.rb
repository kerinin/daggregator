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
    self
  end

  def upstream_sum(key)
    query = <<-CYPHER
      start n=node({id})
      match (n)<-[*..]-(source)
      where source.value
      return sum(source.#{key}) as #{key}
    CYPHER
    if response = execute_query(query, {id: node_id})
      response["data"].first.first
    end
  end

  def upstream_count(key)
    query = <<-CYPHER
      start n=node({id})
      match (n)<-[*..]-(source)
      where source.value
      return count(source) as count
    CYPHER
    if response = execute_query(query, {id: node_id})
      response["data"].first.first
    end
  end
 
  def target_identifiers
    # response = QueryBuilder.new(match: '(n)-->(target)', ret: 'target.identifier').execute
    query = <<-CYPHER
      start n=node({id})
      match (n)-->(target)
      return target.identifier
    CYPHER
    if response = execute_query(query, {id: node_id})
      response["data"].map(&:first)
    end
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

  class QueryBuilder
    attr_accessor :start, :match, :where, :return, :params

    def initialize(params)
      @start =  params[:start] ||   "start n=node(#{node_id})"    # Default to starting at this node
      @match =  params[:match] ||   "match (n)<-[*..]-(source)"   # Default to matching upstream nodes
      @where =  params[:where]
      @return = params[:return]
      @params = params[:params] ||  {}
    end

    def execute
      $neo.execute_query( [start, match, where, ret].compact.join(' '), params)
    end
  end
end
