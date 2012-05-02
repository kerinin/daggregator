class Node
  # extend ActiveModel::Naming
  # extend ActiveModel::Callbacks
  # include ActiveModel::Validations
  # include ActiveModel::AttributeMethods
  # include ActiveModel::Dirty
  include ActiveModel::SerializerSupport

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
    if response = query.match("(n)<-[*..]-(source)").where("source.#{key}").return("sum(source.#{key}) as #{key}").execute
      # binding.pry
      if result = response["data"].first
        # If there are results
        result.first
      else
        # If this key isn't defined upstream
        nil
      end
    end
  end

  def upstream_count(key)
    if response = query.match("(n)<-[*..]-(source)").where("source.#{key}").return("count(source) as count").execute
      response["data"].first.first
    end
  end
 
  def target_identifiers
    if response = query.match("(n)-->(target)").return("target.identifier").execute
      response["data"].map(&:first)
    end
  end

  # Private Methods
  
  def query
    QueryBuilder.new(node_id)
  end

  def fetch_node_attributes
    response = $neo.get_node_index(:identifier, 'identifier', identifier)
    data.merge! response.first['data']
    data.delete('identifier')
    @node_url = response.first['self']
    response.first
  end

  def set_node_properties(properties)
    response = $neo.create_unique_node(:identifier, 'identifier', identifier, {'identifier' => identifier}.merge(data))
  end

  class QueryBuilder
    attr_accessor :query_elements

    def initialize(node_id)
      @query_elements = {}
      query_elements[:start] = "n=node(#{node_id})"    # Default to starting at this node
    end

    def start(condtiion)
      query_elements[:start] = condition
      self
    end

    def where(condition)
      query_elements[:where] = condition
      self
    end

    def match(condition)
      query_elements[:match] = condition
      self
    end

    def return(condition)
      query_elements[:return] = condition
      self
    end

    def query_string
      query_elements.reject {|k,v| v.nil?}.flatten.join(' ')
    end

    def execute(params={})
      $neo.execute_query( query_string, params)
    end
  end
end
