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

  def persisted?
    not node_id.nil?
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
    result_or(nil) do
      query.match("(n)<-[*..]-(source)").where("has(source.#{key})").return("sum(source.#{key})").execute
    end
  end

  def upstream_count(key, value=nil)
    result_or(0) do
      if value
        # Match upstream with key=value
        escaped_value = (value.kind_of?(String) ? "'#{value}'" : value.to_s)

        query.match("(n)<-[*..]-(source)").where("source.#{key}! = #{escaped_value}").return("count(source.#{key})").execute
      else
        # Match upstream with key=anything
        query.match("(n)<-[*..]-(source)").where("has(source.#{key})").return("count(source.#{key})").execute
      end
    end
  end

  def upstream_distribution(key)
    # Get all the unique values of key
    values = result_or([]) do
      query.match("(n)<-[*..]-(source)").where("has(source.#{key})").return("collect(source.#{key})").execute
    end

    # Build a hash with unique values as keys and count occurrances upstream as values
    result = {}
    values.each do |value|
      if count = upstream_count(key, value)
        result[value] = count
      end
    end
    result.empty? ? nil : result
  end

  def upstream_bin_count(key, bins)
    bins = bins.to_i
    min, max = upstream_key_range(key)

    result = {}
    unless min.nil? or max.nil? or min == max
      range = max - min
      interval = range.to_f / bins
      bins.times do |i|
        lower         = min + (interval * i)
        upper        = min + (interval * (1+i))
        range         = "[#{lower},#{upper}#{(i+1 == bins ? "]" : ")")}"
        result[range] = upstream_range_count(key, lower, upper, (i+1) == bins)
      end
    end
    result.empty? ? nil : result
  end
 
  def upstream_range_count(key, lower, upper, upper_inclusive=false)
    # binding.pry
    result_or(0) do
      query.match("(n)<-[*..]-(source)").where("(source.#{key}! >= #{lower}) and (source.#{key}! #{upper_inclusive ? '<=' : '<'} #{upper})").return("count(source)").execute
    end
  end

  def upstream_key_range(key)
    min = result_or(nil) do
      query.match("(n)<-[*..]-(source)").where("has(source.#{key})").return("min(source.#{key})").execute
    end
    max = result_or(nil) do
      query.match("(n)<-[*..]-(source)").where("has(source.#{key})").return("max(source.#{key})").execute
    end
    [min.to_f, max.to_f]
  end

  def target_identifiers
    if response = query.match("(n)-->(target)").return("target.identifier").execute
      response["data"].map(&:first)
    end
  end

  # Private Methods

  def result_or(default)
    if response = yield
      if result = response["data"].first
        result.first
      else
        default
      end
    else
      default
    end
  end
  
  def query
    QueryBuilder.new(node_id)
  end

  def fetch_node_attributes
    neo(:get_node_index, :identifier, 'identifier', identifier) do |result|
      data.merge! result['data']
      data.delete('identifier')
      @node_url = result['self']
    end
  end

  def set_node_properties(properties)
    neo(
      :create_unique_node, 
      :identifier, 
      'identifier', 
      identifier, 
      {'identifier' => identifier}.merge(data)
    )
  end

  def neo(function, *args, &block)
    response = $neo.send(function, *args)
    yield response.first if block and response
    response.try(:first)
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
