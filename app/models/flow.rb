class Flow
  attr_accessor :source, :target

  def self.create(source_node, target_node)
    Flow.new(source_node, target_node).save!
  end

  def initialize(source_node, target_node)
    @source = source_node
    @target = target_node
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
    set_flow_properties
    self
  end

  # Private Methods

  def set_flow_properties(properties={})
    response = $neo.create_unique_relationship(
      :flow_node_pairs, 
      "node_pair", 
      "#{@source.identifier}:#{@target.identifier}",
      "flow",
      @source.node_url,
      @target.node_url
    )
  end
end
