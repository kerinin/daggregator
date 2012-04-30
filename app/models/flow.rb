class Flow
  attr_accessor :source, :target

  def initialize(source_node, target_node)
    @source = source_node
    @target = target_node
  end

  def save!
    self
  end
end
